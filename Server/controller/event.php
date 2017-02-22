<?php
/**
 * Created by PhpStorm.
 * User: jacobmay415
 * Date: 12/27/16
 * Time: 3:59 AM
 */

function createEvent($req, $res) {
    global $db;

    $user_id = validateUserAuthentication($req);
    if($user_id) {
        $params = $req->getParams();
        $files = $req->getUploadedFiles();

        if (isset($files['event_photo'])) {
            $event_photo_url = 'Event_' . generateRandomString(40) . '.jpg';
            $files['event_photo']->moveTo('assets/images/' . $event_photo_url);
        } else {
            $event_photo_url = '';
        }

        $query = $db->prepare('insert into tblEvent (event_user_id,
                                                     event_name,
                                                     event_photo_url,
                                                     event_description,
                                                     event_latitude,
                                                     event_longitude,
                                                     event_time,
                                                     event_type,
                                                     event_enable_uber)
                                             values (:event_user_id,
                                                    :event_name,
                                                    :event_photo_url,
                                                    :event_description,
                                                    :event_latitude,
                                                    :event_longitude,
                                                    :event_time,
                                                    :event_type,
                                                    :event_enable_uber)');
        $query->bindParam(':event_user_id', $user_id);
        $query->bindParam(':event_name', $params['event_name']);
        $query->bindParam(':event_photo_url', $event_photo_url);
        $query->bindParam(':event_description', $params['event_description']);
        $query->bindParam(':event_latitude', $params['event_latitude']);
        $query->bindParam(':event_longitude', $params['event_longitude']);
        $query->bindParam(':event_time', $params['event_time']);
        $query->bindParam(':event_type', $params['event_type']);
        $query->bindParam(':event_enable_uber', $params['event_enable_uber']);
        if($query->execute()) {
            $query = $db->prepare('select * from tblEvent where event_id = :event_id');
            $query->bindParam(':event_id', $db->lastInsertId());
            if($query->execute()) {
                $event = $query->fetch(PDO::FETCH_NAMED);
                $newRes = makeResultResponseWithObject($res, 200, $event);
            } else {
                $newRes = makeResultResponseWithString($res, 400, $query->errorInfo()[2]);
            }
        } else {
            $newRes = makeResultResponseWithString($res, 400, $query->errorInfo()[2]);
        }
    } else {
        $newRes = makeResultResponseWithString($res, 401, 'Your token has expired. Please login again.');
    }

    return $newRes;
}

function getActiveEvents($req, $res) {
    global $db;

    $user_id = validateUserAuthentication($req);
    if($user_id) {
        $query = $db->prepare('select * from tblEvent where (adddate(event_time, INTERVAL 1 DAY) > now()
                                                              and (event_type = "PUBLIC"
                                                                    or (event_type = "SEMI-PUBLIC" and event_email_verified = 1)
                                                                    or (event_type = "PRIVATE" and (select count(*) from tblEventInvite where event_invite_event_id = tblEvent.event_id and event_invite_user_id = :user_id and event_invite_accept = 1) > 0)))
                                                         or event_user_id = :user_id
                                                         or event_id = 1');
        $query->bindParam(':user_id', $user_id);
        if($query->execute()) {
            $events = $query->fetchAll(PDO::FETCH_ASSOC);
            $aryEvents = [];
            foreach ($events as $event) {
                $event['event_medias'] = json_decode(\Httpful\Request::get(WEB_SERVER . '/api/v1/events/' . $event['event_id'] . '/medias')
                    ->addHeader(HTTP_HEADER_ACCESS_TOKEN, $req->getHeaderLine(HTTP_HEADER_ACCESS_TOKEN))
                    ->send(), true);

                $event['event_vibes'] = json_decode(\Httpful\Request::get(WEB_SERVER . '/api/v1/events/' . $event['event_id'] . '/vibes')
                    ->addHeader(HTTP_HEADER_ACCESS_TOKEN, $req->getHeaderLine(HTTP_HEADER_ACCESS_TOKEN))
                    ->send(), true);

                $event['event_users'] = json_decode(\Httpful\Request::get(WEB_SERVER . '/api/v1/events/' . $event['event_id'] . '/users')
                    ->addHeader(HTTP_HEADER_ACCESS_TOKEN, $req->getHeaderLine(HTTP_HEADER_ACCESS_TOKEN))
                    ->send(), true);

                array_push($aryEvents, $event);
            }

            $newRes = makeResultResponseWithObject($res, 200, $aryEvents);
        } else {
            $newRes = makeResultResponseWithString($res, 400, $query->errorInfo()[2]);
        }
    } else {
        $newRes = makeResultResponseWithString($res, 401, 'Your token has expired. Please login again.');
    }

    return $newRes;
}

function getEventVibes($req, $res, $args) {
    global $db;

    $user_id = validateUserAuthentication($req);
    if($user_id) {
        $query = $db->prepare('select * from viewEventVibe where vibe_event_id = :vibe_event_id 
                                                             and vibe_created_at < adddate(now(), INTERVAL 1 DAY)
                                                        order by (vibe_likes - vibe_dislikes) desc');
        $query->bindParam(':vibe_event_id', $args['id']);
        if($query->execute()) {
            $vibes = $query->fetchAll(PDO::FETCH_ASSOC);

            $aryVibes = [];
            foreach ($vibes as $vibe) {
                $query = $db->prepare('select * from tblVibeVote where vibe_vote_user_id = :user_id
                                                                   and vibe_vote_vibe_id = :vibe_id');
                $query->bindParam(':user_id', $user_id);
                $query->bindParam(':vibe_id', $vibe['vibe_id']);
                if($query->execute()) {
                    $read_count = count($query->fetchAll(PDO::FETCH_ASSOC));
                    $vibe['vibe_is_vote'] = $read_count > 0;
                } else {
                    continue;
                }

                array_push($aryVibes, $vibe);
            }

            $newRes = makeResultResponseWithObject($res, 200, $aryVibes);
        } else {
            $newRes = makeResultResponseWithString($res, 400, $query->errorInfo()[2]);
        }
    } else {
        $newRes = makeResultResponseWithString($res, 401, 'Your token has expired. Please login again.');
    }

    return $newRes;
}

function createEventVibe($req, $res, $args) {
    global $db;

    $user_id = validateUserAuthentication($req);
    if($user_id) {
        $params = $req->getParams();

        $query = $db->prepare('insert into tblEventVibe (vibe_event_id,
                                                         vibe_text)
                                                values (:vibe_event_id,
                                                        :vibe_text)');
        $query->bindParam(':vibe_event_id', $args['id']);
        $query->bindParam(':vibe_text', $params['vibe_text']);
        if($query->execute()) {
            $query = $db->prepare('select * from tblEventVibe where vibe_id = :vibe_id');
            $query->bindParam(':vibe_id', $db->lastInsertId());
            if($query->execute()) {
                $vibe = $query->fetch(PDO::FETCH_NAMED);
                $newRes = makeResultResponseWithObject($res, 200, $vibe);
            } else {
                $newRes = makeResultResponseWithString($res, 400, $query->errorInfo()[2]);
            }
        } else {
            $newRes = makeResultResponseWithString($res, 400, $query->errorInfo()[2]);
        }
    } else {
        $newRes = makeResultResponseWithString($res, 401, 'Your token has expired. Please login again.');
    }

    return $newRes;
}

function uploadImage($req, $res, $args) {
    global $db;

    $user_id = validateUserAuthentication($req);
    if($user_id) {
        $params = $req->getParams();
        $files = $req->getUploadedFiles();

        if (isset($files['media_photo'])) {
            $media_photo_url = 'Photo_' . generateRandomString(40) . '.jpg';
            $files['media_photo']->moveTo('assets/images/' . $media_photo_url);
        } else {
            $media_photo_url = '';
        }

        $query = $db->prepare('insert into tblEventMedia (media_user_id,
                                                          media_event_id,
                                                          media_photo_url,
                                                          media_type)
                                                  values (:media_user_id,
                                                          :media_event_id,
                                                          :media_photo_url,
                                                          :media_type)');
        $query->bindParam(':media_user_id', $user_id);
        $query->bindParam(':media_event_id', $args['id']);
        $query->bindParam(':media_photo_url', $media_photo_url);
        $query->bindParam(':media_type', $params['media_type']);
        if($query->execute()) {
            $query = $db->prepare('select * from tblEventMedia where media_id = :media_id');
            $query->bindParam(':media_id', $db->lastInsertId());
            if($query->execute()) {
                $media = $query->fetch(PDO::FETCH_NAMED);
                $media['media_is_read'] = true;
                $newRes = makeResultResponseWithObject($res, 200, $media);
            } else {
                $newRes = makeResultResponseWithString($res, 400, $query->errorInfo()[2]);
            }
        } else {
            $newRes = makeResultResponseWithString($res, 400, $query->errorInfo()[2]);
        }
    } else {
        $newRes = makeResultResponseWithString($res, 401, 'Your token has expired. Please login again.');
    }

    return $newRes;
}

function uploadVideo($req, $res, $args) {
    global $db;

    $user_id = validateUserAuthentication($req);
    if($user_id) {
        $files = $req->getUploadedFiles();

        if (isset($files['media_photo'])) {
            $media_photo_url = 'Photo_' . generateRandomString(40) . '.jpg';
            $files['media_photo']->moveTo('assets/images/' . $media_photo_url);
        } else {
            $media_photo_url = '';
        }

        if (isset($files['media_video'])) {
            $media_video_url = 'Video_' . generateRandomString(40) . '.mov';
            $files['media_video']->moveTo('assets/videos/' . $media_video_url);
        } else {
            $media_video_url = '';
        }

        $query = $db->prepare('insert into tblEventMedia (media_user_id,
                                                          media_event_id,
                                                          media_photo_url,
                                                          media_video_url,
                                                          media_type)
                                                  values (:media_user_id,
                                                          :media_event_id,
                                                          :media_photo_url,
                                                          :media_video_url,
                                                          "VIDEO")');
        $query->bindParam(':media_user_id', $user_id);
        $query->bindParam(':media_event_id', $args['id']);
        $query->bindParam(':media_photo_url', $media_photo_url);
        $query->bindParam(':media_video_url', $media_video_url);
        if($query->execute()) {
            $query = $db->prepare('select * from tblEventMedia where media_id = :media_id');
            $query->bindParam(':media_id', $db->lastInsertId());
            if($query->execute()) {
                $media = $query->fetch(PDO::FETCH_NAMED);
                $media['media_is_read'] = true;
                $newRes = makeResultResponseWithObject($res, 200, $media);
            } else {
                $newRes = makeResultResponseWithString($res, 400, $query->errorInfo()[2]);
            }
        } else {
            $newRes = makeResultResponseWithString($res, 400, $query->errorInfo()[2]);
        }
    } else {
        $newRes = makeResultResponseWithString($res, 401, 'Your token has expired. Please login again.');
    }

    return $newRes;
}

function getEventMedias($req, $res, $args) {
    global $db;

    $user_id = validateUserAuthentication($req);
    if($user_id) {
        $query = $db->prepare('select * from tblEventMedia where media_event_id = :media_event_id
                                                        order by media_created_at desc');
        $query->bindParam(':media_event_id', $args['id']);
        if($query->execute()) {
            $medias = $query->fetchAll(PDO::FETCH_ASSOC);

            $aryMedias = [];
            foreach ($medias as $media) {
                if($media['media_user_id'] == $user_id) {
                    $media['media_is_read'] = true;
                } else {
                    $query = $db->prepare('select * from tblMediaRead where media_read_user_id = :user_id
                                                                    and media_read_media_id = :media_id');
                    $query->bindParam(':user_id', $user_id);
                    $query->bindParam(':media_id', $media['media_id']);
                    if ($query->execute()) {
                        $read_count = count($query->fetchAll(PDO::FETCH_ASSOC));
                        $media['media_is_read'] = $read_count > 0;
                    } else {
                        continue;
                    }
                }

                array_push($aryMedias, $media);
            }
            $newRes = makeResultResponseWithObject($res, 200, $aryMedias);
        } else {
            $newRes = makeResultResponseWithString($res, 400, $query->errorInfo()[2]);
        }
    } else {
        $newRes = makeResultResponseWithString($res, 401, 'Your token has expired. Please login again.');
    }

    return $newRes;
}

function addEmail($req, $res, $args) {
    global $db;

    $user_id = validateUserAuthentication($req);
    if($user_id) {
        $verification_email = WEB_SERVER . '/api/v1/events/' . $args['id'] . '/verify/email';

        $params = $req->getParams();
        $query = $db->prepare('select * from tblUser where user_id = :user_id');
        $query->bindParam(':user_id', $user_id);
        if($query->execute()) {
            $user = $query->fetch(PDO::FETCH_NAMED);

            $query = $db->prepare('update tblEvent set event_email = :event_email
                                                 where event_id = :event_id');
            $query->bindParam(':event_id', $args['id']);
            $query->bindParam(':event_email', $params['event_email']);

            if ($query->execute()) {
                // send email
                $strEmail = file_get_contents('email/email1.html');
                $strEmail .= ' ' . $user['user_name'];
                $strEmail .= file_get_contents('email/email2.html');
                $strEmail .= ' <a href="' . $verification_email . '">' . $verification_email . '</a>';
                $strEmail .= file_get_contents('email/email3.html');

                sendEmail('Please verify your email address', $strEmail, $params['event_email']);

                $newRes = makeResultResponseWithString($res, 200, 'Verification email sent to you.');
            } else {
                $newRes = makeResultResponseWithString($res, 400, $query->errorInfo()[2]);
            }
        } else {
            $newRes = makeResultResponseWithString($res, 400, $query->errorInfo()[2]);
        }
    } else {
        $newRes = makeResultResponseWithString($res, 401, 'Your token has expired. Please login again.');
    }

    return $newRes;
}

function verifyEmail($req, $res, $args) {
    global $db;

    $query = $db->prepare('update tblEvent set event_email_verified = 1 where event_id = :event_id');
    $query->bindParam(':event_id', $args['id']);
    if($query->execute()) {
        $newRes = $res->withStatus(302)->withHeader('Location', WEB_SERVER . '/api/email/email_verified.html');
    } else {
        $newRes = makeResultResponseWithString($res, 400, $query->errorInfo()[2]);
    }

    return $newRes;
}

function getEventUsers($req, $res, $args) {
    global $db;

    $user_id = validateUserAuthentication($req);
    if($user_id) {
        $query = $db->prepare('select * from viewEventUser where event_user_event_id = :event_id');
        $query->bindParam(':event_id', $args['id']);
        if($query->execute()) {
            $users = $query->fetchAll(PDO::FETCH_ASSOC);
            $newRes = makeResultResponseWithObject($res, 200, $users);
        } else {
            $newRes = makeResultResponseWithString($res, 400, $query->errorInfo()[2]);
        }
    } else {
        $newRes = makeResultResponseWithString($res, 401, 'Your token has expired. Please login again.');
    }

    return $newRes;
}