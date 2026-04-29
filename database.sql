CREATE DATABASE IF NOT EXISTS `gym_db`;
USE `gym_db`;

CREATE TABLE `courses` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `course_date` date NOT NULL,
  `available_spots` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `course_bookings` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `course_id` int(11) NOT NULL,
  `user_email` varchar(100) NOT NULL,
  `booking_date` timestamp NOT NULL DEFAULT current_timestamp(),
  FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Inserimento di dati di prova
INSERT INTO `courses` (`title`, `description`, `course_date`, `available_spots`) VALUES
('Yoga', 'Sessione rilassante di Yoga.', '2026-05-10', 15),
('Crossfit', 'Allenamento ad alta intensità.', '2026-05-11', 10);
