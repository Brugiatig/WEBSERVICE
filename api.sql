<?php
// Impostazione degli header per il Web Service (REST/JSON)
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST");

// 1. CONNESSIONE AL DATABASE (XAMPP default)
$host = "localhost";
$db_name = "gym_db";
$username = "root"; 
$password = "";

try {
    $conn = new PDO("mysql:host=$host;dbname=$db_name;charset=utf8", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $exception) {
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Errore di connessione: " . $exception->getMessage()]);
    exit;
}

// 2. LOGICA DEL WEB SERVICE
$action = isset($_GET['action']) ? $_GET['action'] : '';

switch($action) {
    
    // Ottenere i corsi disponibili
    case 'get_courses':
        $stmt = $conn->prepare("SELECT * FROM courses WHERE available_spots > 0 ORDER BY course_date ASC");
        $stmt->execute();
        $courses = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        http_response_code(200);
        echo json_encode(["status" => "success", "data" => $courses]);
        break;

    // Prenotare un corso
    case 'book':
        // Ricezione del payload JSON inviato dal client
        $data = json_decode(file_get_contents("php://input"));
        
        if(!empty($data->course_id) && !empty($data->user_email)) {
            
            // Controllo disponibilità posti
            $check = $conn->prepare("SELECT available_spots FROM courses WHERE id = ?");
            $check->execute([$data->course_id]);
            $course = $check->fetch(PDO::FETCH_ASSOC);

            if($course && $course['available_spots'] > 0){
                
                $conn->beginTransaction();
                try {
                    // Inserimento prenotazione
                    $book = $conn->prepare("INSERT INTO course_bookings (course_id, user_email) VALUES (?, ?)");
                    $book->execute([$data->course_id, $data->user_email]);

                    // Riduzione dei posti disponibili
                    $update = $conn->prepare("UPDATE courses SET available_spots = available_spots - 1 WHERE id = ?");
                    $update->execute([$data->course_id]);

                    $conn->commit();
                    http_response_code(201); // 201 Created
                    echo json_encode(["status" => "success", "message" => "Prenotazione confermata."]);
                } catch(Exception $e) {
                    $conn->rollBack();
                    http_response_code(500);
                    echo json_encode(["status" => "error", "message" => "Errore durante la prenotazione."]);
                }
            } else {
                http_response_code(400); // 400 Bad Request
                echo json_encode(["status" => "error", "message" => "Posti esauriti o corso inesistente."]);
            }
        } else {
            http_response_code(400);
            echo json_encode(["status" => "error", "message" => "Dati mancanti. Richiesti course_id e user_email."]);
        }
        break;

    // Nessuna azione valida fornita
    default:
        http_response_code(404); // 404 Not Found
        echo json_encode(["status" => "error", "message" => "Azione non specificata o non valida. Utilizzare ?action=get_courses oppure ?action=book"]);
        break;
}
?>
