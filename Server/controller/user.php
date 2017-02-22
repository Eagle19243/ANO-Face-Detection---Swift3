<?php
/**
 * Created by PhpStorm.
 * User: kevinlee0621
 * Date: 2/4/16
 * Time: 8:29 PM
 */

function signup($req, $res) {
    global $db;

    $params = $req->getParams();

    $query = $db->prepare('insert into tblUser (user_name,
                                                user_pass,
                                                user_phone,
                                                user_device_token,
                                                user_device_type) values
                                                (:user_name,
                                                HEX(AES_ENCRYPT(:user_pass, \'' . DB_USER_PASSWORD . '\')),
                                                :user_phone,
                                                :user_device_token,
                                                :user_device_type)');

    $query->bindParam(':user_name', $params['user_name']);
    $query->bindParam(':user_pass', $params['user_pass']);
    $query->bindParam(':user_phone', $params['user_phone']);
    $query->bindParam(':user_device_token', $params['user_device_token']);
    $query->bindParam(':user_device_type', $params['user_device_type']);

    if($query->execute()) {
        $query = $db->prepare('select * from tblUser where user_id = :user_id');
        $query->bindParam(':user_id', $db->lastInsertId());
        if($query->execute()) {
            $user = $query->fetch(PDO::FETCH_NAMED);
            $newRes = makeResultResponseWithObject($res, 200, getUserInformation($user, false));
        } else {
            $newRes = makeResultResponseWithString($res, 400, $query->errorInfo()[2]);
        }
    } else {
        if($query->errorInfo()[1] == 1062) {
            $newRes = makeResultResponseWithString($res, 409, 'This username is already used in ANO');
        } else {
            $newRes = makeResultResponseWithString($res, 400, $query->errorInfo()[2]);
        }
    }

    return $newRes;
}

function login($req, $res) {
    global $db;

    $params = $req->getParams();

    $query = $db->prepare('select * from tblUser where
                            (user_name = :user_name and user_pass = HEX(AES_ENCRYPT(:user_pass, \'' . DB_USER_PASSWORD . '\')))');
    $query->bindParam(':user_name', $params['user_name']);
    $query->bindParam(':user_pass', $params['user_pass']);
    $query->execute();
    $user = $query->fetch(PDO::FETCH_NAMED);
    if($user) {
        $query = $db->prepare('update tblUser set user_device_token = :user_device_token,
                                              user_device_type = :user_device_type
                           where user_id = :user_id');
        $query->bindParam(':user_device_token', $params['user_device_token']);
        $query->bindParam(':user_device_type', $params['user_device_type']);
        $query->bindParam(':user_id', $user['user_id']);
        if($query->execute()) {
            $user['user_device_token'] = $params['user_device_token'];
            $user['user_device_type'] = $params['user_device_type'];

            $newRes = makeResultResponseWithObject($res, 200, getUserInformation($user));
        } else {
            $newRes = makeResultResponseWithString($res, 400, $query->errorInfo()[2]);
        }
    } else {
        $newRes = makeResultResponseWithString($res, 400, 'Your email or password is invalid');
    }

    return $newRes;
}

function updateUser($req, $res) {
    global $db;

    $user_id = validateUserAuthentication($req);
    if($user_id) {
        $params = $req->getParams();

        $query = $db->prepare('update tblUser set user_gender = :user_gender,
                                                  user_birthday = :user_birthday,
                                                  user_stats = :user_stats
                                            where user_id = :user_id');
        $query->bindParam(':user_id', $user_id);
        $query->bindParam(':user_gender', $params['user_gender']);
        $query->bindParam(':user_birthday', $params['user_birthday']);
        $query->bindParam(':user_stats', $params['user_stats']);

        if ($query->execute()) {
            $newRes = makeResultResponseWithString($res, 200, 'User updated successfully');
        } else {
            $newRes = makeResultResponseWithString($res, 400, $query->errorInfo()[2]);
        }
    } else {
        $newRes = makeResultResponseWithString($res, 401, 'Your token has expired. Please login again.');
    }

    return $newRes;
}

function getUserInformation($user, $isLogin = true) {
    $me = [];

    $me['my_access_token'] = createUserAccessToken($user['user_id'], $user['user_name']);
    $me['my_user'] = $user;
    if($isLogin) {

    }

    return $me;
}

function createUserAccessToken($user_id, $user_name) {
    global $db;

    $query = $db->prepare('delete from tblToken where token_user_id = :user_id');
    $query->bindParam(':user_id', $user_id);
    $query->execute();

    $token_key = base64_encode('ANOAccessToken=>Start:'.$user_name.'at'.time().':End');
    $query = $db->prepare('insert into tblToken (token_user_id,
                                                  token_key,
                                                  token_expire_at) values
                                                  (:token_user_id,
                                                  HEX(AES_ENCRYPT(:token_key, \'' . DB_USER_PASSWORD . '\')),
                                                  adddate(now(), INTERVAL 1 MONTH))');
    $query->bindParam(':token_user_id', $user_id);
    $query->bindParam(':token_key', $token_key);

    if($query->execute()) {
        $user_access_token = $token_key;
    } else {
        $user_access_token = $query->errorInfo()[2];
    }

    return $user_access_token;
}

function resetPassword($req, $res) {
    global $db;

    $params = $req->getParams();

    $query = $db->prepare('update tblUser set user_pass = HEX(AES_ENCRYPT(:user_pass, \'' . DB_USER_PASSWORD . '\'))
                                      where user_phone = :user_phone');
    $query->bindParam(':user_pass', $params['user_pass']);
    $query->bindParam(':user_phone', $params['user_phone']);
    if($query->execute()) {
        $newRes = makeResultResponseWithString($res, 200, 'Password reset successfully');
    } else {
        $newRes = makeResultResponseWithString($res, 400, $query->errorInfo()[2]);
    }

    return $newRes;
}

function updatePassword($req, $res) {
    global $db;

    $user_id = validateUserAuthentication($req);
    if($user_id) {
        $params = $req->getParams();

        $query = $db->prepare('select AES_DECRYPT(UNHEX(user_pass), \'' . DB_USER_PASSWORD . '\') as user_pass from tblUser where user_id = :user_id');
        $query->bindParam(':user_id', $user_id);
        if($query->execute()) {
            $result = $query->fetch(PDO::FETCH_NAMED);
            if ($result['user_pass'] == $params['user_current_pass']) {
                $query = $db->prepare('update tblUser set user_pass = HEX(AES_ENCRYPT(:user_pass, \'' . DB_USER_PASSWORD . '\'))
                                                  where user_id = :user_id');
                $query->bindParam(':user_id', $user_id);
                $query->bindParam(':user_pass', $params['user_new_pass']);

                if ($query->execute()) {
                    $newRes = makeResultResponseWithString($res, 200, 'Password updated successfully');
                } else {
                    $newRes = makeResultResponseWithString($res, 400, $query->errorInfo()[2]);
                }

            } else {
                $newRes = makeResultResponseWithString($res, 400, 'Your current password is wrong.');
            }
        } else {
            $newRes = makeResultResponseWithString($res, 400, $query->errorInfo()[2]);
        }
    } else {
        $newRes = makeResultResponseWithString($res, 401, 'Your token has expired. Please login again.');
    }

    return $newRes;
}

function attendUser($req, $res, $args) {
    global $db;

    $user_id = validateUserAuthentication($req);
    if($user_id) {
        $query = $db->prepare('insert into tblEventUser (event_user_user_id, 
                                                         event_user_event_id)
                                                 values (:user_id,
                                                         :event_id)');
        $query->bindParam(':user_id', $user_id);
        $query->bindParam(':event_id', $args['id']);
        if($query->execute()) {
            $newRes = makeResultResponseWithString($res, 200, 'Attended event successfully');
        } else {
            $newRes = makeResultResponseWithString($res, 400, $query->errorInfo()[2]);
        }
    } else {
        $newRes = makeResultResponseWithString($res, 401, 'Your token has expired. Please login again.');
    }

    return $newRes;
}

function logout($req, $res, $args = []) {
    global $db;

    $query = $db->prepare('update tblUser set user_device_token = "" where user_id = :user_id');
    $query->bindParam(':user_id', $args['id']);
    if($query->execute()) {
        $newRes = makeResultResponseWithString($res, 200, 'Logged out successfully');
    } else {
        $newRes = makeResultResponseWithString($res, 400, $query->errorInfo()[2]);
    }

    return $newRes;
}



