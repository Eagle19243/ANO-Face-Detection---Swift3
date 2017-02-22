<?php

// Include the SDK using the Composer autoloader
require 'vendor/autoload.php';

// Includes ;
require_once( 'config/database.php' );
require_once( 'controller/base.php' );

$app = new Slim\App();
$twilio = new Twilio\Rest\Client(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN);

$app->group('/v1', function() use ($app) {
    $app->group('/users', function() use ($app) {
        require_once 'controller/user.php';
        $app->post('', 'signup');
        $app->put('', 'updateUser');
        $app->get('/login', 'login');
        $app->patch('/update/password', 'updatePassword');
        $app->patch('/reset/password', 'resetPassword');

        $app->group('/{id}', function() use ($app) {
            $app->delete('/logout', 'logOut');
        });

        $app->post('/events/{id}', 'attendEvent');
    });
    $app->group('/events', function() use ($app) {
        require_once 'controller/event.php';

        $app->post('', 'createEvent');
        $app->get('/active', 'getActiveEvents');

        $app->group('/{id}', function() use ($app) {
            $app->patch('/add/email', 'addEmail');
            $app->get('/verify/email', 'verifyEmail');
            $app->post('/photos', 'uploadImage');
            $app->post('/videos', 'uploadVideo');
            $app->get('/medias', 'getEventMedias');
            $app->group('/vibes', function() use ($app) {
                $app->get('', 'getEventVibes');
                $app->post('', 'createEventVibe');
            });
            $app->get('/users', 'getEventUsers');
        });
    });
    $app->group('/vibes', function() use ($app) {
        require_once 'controller/vibe.php';

        $app->group('/{id}', function () use ($app) {
            $app->post('', 'voteEventVibe');
        });
    });
    $app->group('/medias', function() use ($app) {
        require_once 'controller/media.php';

        $app->group('/{id}', function () use ($app) {
            $app->post('/report', 'reportEventMedia');
            $app->post('/read', 'readEventMedia');
        });
    });

    $app->post('/send/code', 'sendVerificationCode');
    $app->any('/document', 'getAPIDoc');
});

$app->run();

function getAPIDoc($req, $res) {
    $strJson = file_get_contents('docs/swagger.json');

    $newRes = $res->withStatus(200)
        ->withHeader('Content-Type', 'application/json;charset=utf-8')
        ->write($strJson);

    return $newRes;
}

function sendVerificationCode($req, $res) {
    global $db;

    $params = $req->getParams();
    if ($params['is_sign_up'] == true) {
        $query = $db->prepare('select * from tblUser where user_phone = :user_phone');
        $query->bindParam(':user_phone', $params['phone_number']);
        if ($query->execute()) {
            $user = $query->fetch(PDO::FETCH_NAMED);
            if ($user) {
                $newRes = makeResultResponseWithString($res, 400, 'This phone number exists in ANO. Please input other number');
            } else {
                $result = sendSMS($params['phone_number'], $params['verification_code']);
                if ($result == '') {
                    $newRes = makeResultResponseWithString($res, 200, 'Verification code sent to your phone.');
                } else {
                    $newRes = makeResultResponseWithString($res, 400, $result);
                }
            }
        } else {
            $newRes = makeResultResponseWithString($res, 400, $query->errorInfo()[2]);
        }
    } else {
        $query = $db->prepare('select * from tblUser where user_phone = :user_phone');
        $query->bindParam(':user_phone', $params['phone_number']);
        if ($query->execute()) {
            $user = $query->fetch(PDO::FETCH_NAMED);
            if ($user) {
                $result = sendSMS($params['phone_number'], $params['verification_code']);
                if($result == '') {
                    $newRes = makeResultResponseWithString($res, 200, 'Verification code sent to your phone.');
                } else {
                    $newRes = makeResultResponseWithString($res, 400, $result);
                }
            } else {
                $newRes = makeResultResponseWithString($res, 400, 'This phone number doesn\'t exist in ANO.');
            }
        } else {
            $newRes = makeResultResponseWithString($res, 400, $query->errorInfo()[2]);
        }
    }

    return $newRes;
}
