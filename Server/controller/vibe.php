<?php
/**
 * Created by PhpStorm.
 * User: jacobmay415
 * Date: 12/27/16
 * Time: 4:00 AM
 */

function voteEventVibe($req, $res, $args) {
    global $db;

    $user_id = validateUserAuthentication($req);
    if($user_id) {
        $params = $req->getParams();

        $query = $db->prepare('select * from tblVibeVote where vibe_vote_user_id = :vibe_vote_user_id
                                                           and vibe_vote_vibe_id = :vibe_vote_vibe_id');
        $query->bindParam(':vibe_vote_user_id', $user_id);
        $query->bindParam(':vibe_vote_vibe_id', $args['id']);
        if($query->execute()) {
            $vibe_actions = $query->fetchAll(PDO::FETCH_ASSOC);
            if(count($vibe_actions) == 0) {
                $query = $db->prepare('insert into tblVibeVote (vibe_vote_user_id,
                                                          vibe_vote_vibe_id,
                                                          vibe_vote_type)
                                                  values (:vibe_vote_user_id,
                                                          :vibe_vote_vibe_id,
                                                          :vibe_vote_type)');
                $query->bindParam(':vibe_vote_user_id', $user_id);
                $query->bindParam(':vibe_vote_vibe_id', $args['id']);
                $query->bindParam(':vibe_vote_type', $params['vibe_vote_type']);
                if ($query->execute()) {
                    $newRes = makeResultResponseWithString($res, 200, 'Voted vite successfully.');
                } else {
                    $newRes = makeResultResponseWithString($res, 400, $query->errorInfo()[2]);
                }
            } else {
                $newRes = makeResultResponseWithString($res, 400, 'You already voted this vibe before.');
            }
        } else {
            $newRes = makeResultResponseWithString($res, 400, $query->errorInfo()[2]);
        }
    } else {
        $newRes = makeResultResponseWithString($res, 401, 'Your token has expired. Please login again.');
    }

    return $newRes;
}