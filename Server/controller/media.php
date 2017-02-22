<?php
/**
 * Created by PhpStorm.
 * User: jacobmay415
 * Date: 12/29/16
 * Time: 12:57 PM
 */
function reportEventMedia($req, $res, $args) {
    global $db;

    $user_id = validateUserAuthentication($req);
    if($user_id) {
        $query = $db->prepare('select * from tblMediaReport where media_report_user_id = :media_report_user_id
                                                              and media_report_media_id = :media_report_media_id');
        $query->bindParam(':media_report_user_id', $user_id);
        $query->bindParam(':media_report_media_id', $args['id']);
        if($query->execute()) {
            $vibe_actions = $query->fetchAll(PDO::FETCH_ASSOC);
            if(count($vibe_actions) == 0) {
                $query = $db->prepare('insert into tblMediaReport (media_report_user_id,
                                                                  media_report_media_id)
                                                          values (:media_report_user_id,
                                                                  :media_report_media_id)');
                $query->bindParam(':media_report_user_id', $user_id);
                $query->bindParam(':media_report_media_id', $args['id']);
                if ($query->execute()) {
                    $newRes = makeResultResponseWithString($res, 200, 'Reported media successfully.');
                } else {
                    $newRes = makeResultResponseWithString($res, 400, $query->errorInfo()[2]);
                }
            } else {
                $newRes = makeResultResponseWithString($res, 400, 'You already reported media before.');
            }
        } else {
            $newRes = makeResultResponseWithString($res, 400, $query->errorInfo()[2]);
        }
    } else {
        $newRes = makeResultResponseWithString($res, 401, 'Your token has expired. Please login again.');
    }

    return $newRes;
}

function readEventMedia($req, $res, $args) {
    global $db;

    $user_id = validateUserAuthentication($req);
    if($user_id) {
        $query = $db->prepare('select * from tblMediaRead where media_read_user_id = :media_read_user_id
                                                            and media_read_media_id = :media_read_media_id');
        $query->bindParam(':media_read_user_id', $user_id);
        $query->bindParam(':media_read_media_id', $args['id']);
        if($query->execute()) {
            $read_actions = $query->fetchAll(PDO::FETCH_ASSOC);
            if(count($read_actions) == 0) {
                $query = $db->prepare('insert into tblMediaRead (media_read_user_id,
                                                                 media_read_media_id)
                                                         values (:media_read_user_id,
                                                                 :media_read_media_id)');
                $query->bindParam(':media_read_user_id', $user_id);
                $query->bindParam(':media_read_media_id', $args['id']);
                if ($query->execute()) {
                    $newRes = makeResultResponseWithString($res, 200, 'Mark media as read successfully.');
                } else {
                    $newRes = makeResultResponseWithString($res, 400, $query->errorInfo()[2]);
                }
            } else {
                $newRes = makeResultResponseWithString($res, 400, 'You already read media before.');
            }
        } else {
            $newRes = makeResultResponseWithString($res, 400, $query->errorInfo()[2]);
        }
    } else {
        $newRes = makeResultResponseWithString($res, 401, 'Your token has expired. Please login again.');
    }

    return $newRes;
}