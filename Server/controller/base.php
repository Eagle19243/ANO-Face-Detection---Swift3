<?php

/**
 * Created by PhpStorm.
 * User: jhpassion0621
 * Date: 11/16/14
 * Time: 9:34 AM
 */

//notification types

define('CARPOOL_PUSH_SEND_INVITATION',          0);
define('CARPOOL_PUSH_INVITATION_ACCEPT',        1);
define('CARPOOL_PUSH_INVITATION_REJECT',        2);
define('CARPOOL_PUSH_UPDATE_EVENT',             3);
define('CARPOOL_PUSH_UPDATE_EVENT_DRIVER',      4);
define('CARPOOL_PUSH_UPDATE_EVENT_PASSENGER',   5);
define('CARPOOL_PUSH_UPDATE_PROFILE',           6);
define('CARPOOL_PUSH_REMOVE_DRIVER',            7);
define('CARPOOL_PUSH_CREATE_PASSENGER',         8);
define('CARPOOL_PUSH_UPDATE_PASSENGER',         9);
define('CARPOOL_PUSH_REMOVE_PASSENGER',         10);
define('CARPOOL_PUSH_REMOVE_EVENT',             11);

/**
 * @param $deviceToken
 * @param $msg
 * @param $badge
 * @return string
 */

function sendNotification($receiver_id, $msg, $noti_id, $noti_type) {

    global $db;
    $query = $db->prepare('select * from viewUser where user_id = :receiver_id');
    $query->bindParam(':receiver_id', $receiver_id);
    if($query->execute()) {
        $user = $query->fetch(PDO::FETCH_NAMED);

        $deviceToken = $user['user_device_token'];
        $badge = $user['user_noti_badges'];

        if (isset($deviceToken)) {
            sendNotificationToMobiles($deviceToken, $msg, $badge, $noti_id, $noti_type);
        }
    }
}

function sendNotificationToMobiles($deviceToken, $msg, $badge, $noti_id, $noti_type) {
    $data = array(
        'noti_id' => $noti_id,
        'noti_type' => $noti_type
    );

    $fields = array(
        'app_id' => ONESIGNAL_APP_ID,
        'data' => $data,
        'include_player_ids' => array($deviceToken),
        'ios_badgeType' => 'SetTo',
        'ios_badgeCount' => (int) $badge,
        'contents' => array("en" => $msg)
    );

    $fields = json_encode($fields);

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, "https://onesignal.com/api/v1/notifications");
    curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json', 'Authorization: Basic '.ONESIGNAL_RESTAPI_KEY));
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
    curl_setopt($ch, CURLOPT_HEADER, FALSE);
    curl_setopt($ch, CURLOPT_POST, TRUE);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $fields);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);

    $response = curl_exec($ch);
    curl_close($ch);

    return $response;
}

function sendEmail($title, $message, $toEmail)
{
	$headers = "From:no-reply@ANO.com \r\n";
	$headers .= "Content-type:text/html \r\n";

	mail($toEmail, $title, $message, $headers);
}

function sendSMS($to, $text)
{
    global $twilio;

    $result = '';
    try {
        $twilio->messages->create(
            $to,
            [
                "body" => $text,
                "from" => TWILIO_FROM_PHONE_NUMBER
            ]
        );
    } catch(Exception $e) {
        $result = $e->getMessage();
    }

    return $result;
}

function generateRandomString($length = 10)
{
    $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    $charactersLength = strlen($characters);
    $randomString = '';
    for ($i = 0; $i < $length; $i++) {
        $randomString .= $characters[rand(0, $charactersLength - 1)];
    }
    return $randomString;
}

function makeResultResponseWithObject($res, $code, $messages) {
    $newRes = $res->withStatus($code)
        ->withHeader('Content-Type', 'application/json;charset=utf-8')
        ->write(json_encode($messages));

    return $newRes;
}

function makeResultResponseWithString($res, $code, $message) {
    $result['message'] = $message;
    $newRes = $res->withStatus($code)
        ->withHeader('Content-Type', 'application/json;charset=utf-8')
        ->write(json_encode($result));

    return $newRes;
}

function validateUserAuthentication($req)
{
    global $db;

    $isResult = false;

    $access_token = $req->getHeaderLine(HTTP_HEADER_ACCESS_TOKEN);
    $query = $db->prepare('select * from tblToken where token_key = HEX(AES_ENCRYPT(:token_key, \'' . DB_USER_PASSWORD . '\')) and token_expire_at > now()');
    $query->bindParam(':token_key', $access_token);
    if ($query->execute()) {
        $user_access_token = $query->fetch(PDO::FETCH_NAMED);
        if ($user_access_token) {
            $query = $db->prepare('update tblToken set token_expire_at = adddate(now(), INTERVAL 1 MONTH) where token_id = :token_id');
            $query->bindParam(':token_id', $user_access_token['token_id']);
            if ($query->execute()) {
                $isResult = $user_access_token['token_user_id'];
            }
        }
    }

    return $isResult;
}