/* Практическое задание. Урок №3. */

/* Задание # 1.
 * Описание задания (Проанализировать структуру БД vk с помощью скрипта, который мы создали на занятии (les-3.sql), и внести предложения по усовершенствованию (если такие идеи есть). 
 * Создайте у себя БД vk с помощью скрипта из материалов урока. Напишите пожалуйста, всё ли понятно по структуре.)
*/

-- Всё понятно, предложений по усовершенствованию нет.

DROP DATABASE IF EXISTS vk;
CREATE DATABASE vk;
USE vk;
-- Создадим таблицу с пользователями а так же создадим колонки с данными.
CREATE TABLE users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(145) NOT NULL, -- COMMENT "Имя",
  last_name VARCHAR(145) NOT NULL,
  email VARCHAR(145) NOT NULL,
  phone CHAR(11) NOT NULL,
  password_hash CHAR(65) DEFAULT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- NOW()
  UNIQUE INDEX email_unique_idx (email),
  UNIQUE INDEX phone_unique_idx (phone)
);

-- Заполним таблицу, добавим Петю и Васю
INSERT INTO users VALUES (DEFAULT, 'Petya', 'Petukhov', 'petya@mail.com', '89212223334', DEFAULT, DEFAULT);
INSERT INTO users VALUES (DEFAULT, 'Vasya', 'Vasilkov', 'vasya@mail.com', '89212023334', DEFAULT, DEFAULT);

SELECT * FROM users;

-- Создадим таблицу с профилем пользователя, чтобы не хранить все данные в таблице users.
-- 1:1 связь
CREATE TABLE profiles (
  user_id BIGINT UNSIGNED NOT NULL PRIMARY KEY,
  gender ENUM('f', 'm', 'x') NOT NULL, -- CHAR(1)
  birthday DATE NOT NULL,
  photo_id INT UNSIGNED,
  user_status VARCHAR(30),
  city VARCHAR(130),
  country VARCHAR(130),
  CONSTRAINT fk_profiles_users FOREIGN KEY (user_id) REFERENCES users (id) -- ON DELETE CASCADE ON UPDATE CASCADE
);

-- Заполним таблицу, добавим профили для уже созданных Пети и Васи
INSERT INTO profiles VALUES (1, 'm', '1997-12-01', NULL, NULL, 'Moscow', 'Russia'); -- профиль Пети
INSERT INTO profiles VALUES (2, 'm', '1988-11-02', NULL, NULL, 'Moscow', 'Russia'); -- профиль Васи

SELECT * FROM profiles;

-- Создадим таблицу с сообщениями пользователей.
-- Связь многих к многим.
CREATE TABLE messages (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  from_user_id BIGINT UNSIGNED NOT NULL,
  to_user_id BIGINT UNSIGNED NOT NULL,
  txt TEXT NOT NULL, -- txt = ПРИВЕТ
  is_delivered BOOLEAN DEFAULT False,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- NOW()
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки",
  INDEX fk_messages_from_user_idx (from_user_id),
  INDEX fk_messages_to_user_idx (to_user_id),
  CONSTRAINT fk_messages_users_1 FOREIGN KEY (from_user_id) REFERENCES users (id),
  CONSTRAINT fk_messages_users_2 FOREIGN KEY (to_user_id) REFERENCES users (id)
);

-- Добавим два сообщения от Пети к Васе, одно сообщение от Васи к Пете
INSERT INTO messages VALUES (DEFAULT, 1, 2, 'Hi!', 1, DEFAULT, DEFAULT); -- сообщение от Пети к Васе номер 1
INSERT INTO messages VALUES (DEFAULT, 1, 2, 'Vasya!', 1, DEFAULT, DEFAULT); -- сообщение от Пети к Васе номер 2
INSERT INTO messages VALUES (DEFAULT, 2, 1, 'Hi, Petya', 1, DEFAULT, DEFAULT); -- сообщение от Пети к Васе номер 2

SELECT * FROM messages;

-- Создадим таблицу запросов в друзья.
-- Связь многих к многим.
CREATE TABLE friend_requests (
  from_user_id BIGINT UNSIGNED NOT NULL,
  to_user_id BIGINT UNSIGNED NOT NULL,
  accepted BOOLEAN DEFAULT False,
  PRIMARY KEY(from_user_id, to_user_id),
  INDEX fk_friend_requests_from_user_idx (from_user_id),
  INDEX fk_friend_requests_to_user_idx (to_user_id),
  CONSTRAINT fk_friend_requests_users_1 FOREIGN KEY (from_user_id) REFERENCES users (id),
  CONSTRAINT fk_friend_requests_users_2 FOREIGN KEY (to_user_id) REFERENCES users (id)
);

-- Добавим запрос на дружбу от Пети к Васе
INSERT INTO friend_requests VALUES (1, 2, 1);

SELECT * FROM friend_requests;

-- Создадим таблицу сообществ.
-- Связь от одного к многим.
CREATE TABLE communities (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(145) NOT NULL,
  description VARCHAR(245) DEFAULT NULL,
  admin_id BIGINT UNSIGNED NOT NULL,
  INDEX communities_users_admin_idx (admin_id),
  CONSTRAINT fk_communities_users FOREIGN KEY (admin_id) REFERENCES users (id)
);

-- Добавим сообщество с создателем Петей
INSERT INTO communities VALUES (DEFAULT, 'Number1', 'I am number one', 1);

SELECT * FROM communities;

-- Создадим таблицу для хранения информации обо всех участниках всех сообществ.
-- Связь многих к многим

-- Таблица связи пользователей и сообществ
CREATE TABLE communities_users (
  community_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, 
  PRIMARY KEY (community_id, user_id),
  INDEX communities_users_comm_idx (community_id),
  INDEX communities_users_users_idx (user_id),
  CONSTRAINT fk_communities_users_comm FOREIGN KEY (community_id) REFERENCES communities (id),
  CONSTRAINT fk_communities_users_users FOREIGN KEY (user_id) REFERENCES users (id)
);

-- Добавим запись вида Вася участник сообщества Number 1
INSERT INTO communities_users VALUES (1, 2, DEFAULT);

SELECT * FROM communities_users;

-- Создадим таблицу для хранения типов медиа файлов, каталог типов медифайлов.
CREATE TABLE media_types (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name varchar(45) NOT NULL UNIQUE -- изображение, музыка, документ
);

-- Добавим типы в каталог
INSERT INTO media_types VALUES (DEFAULT, 'изображение');
INSERT INTO media_types VALUES (DEFAULT, 'музыка');
INSERT INTO media_types VALUES (DEFAULT, 'документ');

SELECT * FROM media_types;

-- Создадим таблицу всех медиафайлов.
-- Связь от одного к многим.
CREATE TABLE media (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, -- Картинка 1
  user_id BIGINT UNSIGNED NOT NULL,
  media_types_id INT UNSIGNED NOT NULL, -- фото
  file_name VARCHAR(245) DEFAULT NULL COMMENT '/files/folder/img.png',
  file_size BIGINT UNSIGNED,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX media_media_types_idx (media_types_id),
  INDEX media_users_idx (user_id),
  CONSTRAINT fk_media_media_types FOREIGN KEY (media_types_id) REFERENCES media_types (id),
  CONSTRAINT fk_media_users FOREIGN KEY (user_id) REFERENCES users (id)
);

-- Добавим два изображения, которые добавил Петя
INSERT INTO media VALUES (DEFAULT, 1, 1, 'im.jpg', 100, DEFAULT);
INSERT INTO media VALUES (DEFAULT, 1, 1, 'im1.png', 78, DEFAULT);
-- Добавим документ, который добавил Вася
INSERT INTO media VALUES (DEFAULT, 2, 3, 'doc.docx', 1024, DEFAULT);

SELECT * FROM media;

/* Задание # 2.
 * Придумать 2-3 таблицы для БД vk, которую мы создали на занятии (с перечнем полей, указанием индексов и внешних ключей). 
 * Прислать результат в виде скрипта *.sql.

Возможные таблицы:
a. Посты пользователя
b. Лайки на посты пользователей, лайки на медиафайлы
c. Черный список
d. Школы, университеты для профиля пользователя
e. Чаты (на несколько пользователей)
f. Посты в сообществе)
*/

-- (a) Cоздадим таблицу постов пользователей. Посты могут быть с добавлением медиафайлов.
-- 1:1
CREATE TABLE posts (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  txt TEXT NOT NULL, -- txt = сообщение
  media_types_id INT UNSIGNED DEFAULT NULL, -- медиафайлы
  file_name VARCHAR(245) DEFAULT NULL,
  file_size BIGINT UNSIGNED DEFAULT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX post_media_types_idx (media_types_id),
  INDEX post_users_idx (user_id),
  CONSTRAINT fk_posts_users FOREIGN KEY (user_id) REFERENCES users (id)
);

-- Добавим пост, с изображением который добавил Петя
INSERT INTO posts VALUES (DEFAULT, 1, 'Какая красивая радуга!', 1, 'rainbow.jpg', 100, DEFAULT);
-- Добавим пост, с песней который добавил Петя
INSERT INTO posts VALUES (DEFAULT, 2, 'Моя любимая песня', 2, 'wanksta.mp3', 1024, DEFAULT);
-- Добавим пост, с песней который добавил Петя
INSERT INTO posts VALUES (DEFAULT, 1, 'Кто сегодня гулять?', DEFAULT, DEFAULT, DEFAULT, DEFAULT);

SELECT * FROM posts;

-- (b1) Cоздадим таблицу лайков на посты пользователей.
-- Связь многих к многим
CREATE TABLE likes_for_posts (
  posts_id BIGINT UNSIGNED NOT NULL,
  from_user_id BIGINT UNSIGNED NOT NULL,
  to_user_id BIGINT UNSIGNED NOT NULL,
  liked BOOLEAN DEFAULT FALSE,
  INDEX fk_likes_for_posts_from_user_idx (from_user_id),
  INDEX fk_likes_for_posts_to_user_idx (to_user_id),
  CONSTRAINT fk_likes_for_posts_posts_id FOREIGN KEY (posts_id) REFERENCES posts (id),
  CONSTRAINT fk_likes_for_posts_users_1 FOREIGN KEY (from_user_id) REFERENCES users (id),
  CONSTRAINT fk_likes_for_posts_users_2 FOREIGN KEY (to_user_id) REFERENCES users (id)
);
-- Поставим лайк на песню Васе от Пети.
INSERT INTO likes_for_posts VALUES (2, 1, 2, 1);

SELECT * FROM likes_for_posts;

-- (b2) Cоздадим таблицу лайков на медиафайлы.
-- Связь многих к многим
CREATE TABLE likes_for_media (
  media_id BIGINT UNSIGNED NOT NULL,
  from_user_id BIGINT UNSIGNED NOT NULL,
  to_user_id BIGINT UNSIGNED NOT NULL,
  liked BOOLEAN DEFAULT FALSE,
  INDEX fk_likes_for_media_from_user_idx (from_user_id),
  INDEX fk_likes_for_media_to_user_idx (to_user_id),
  CONSTRAINT fk_likes_for_media_media_id FOREIGN KEY (media_id) REFERENCES media (id),
  CONSTRAINT fk_likes_for_media_users_1 FOREIGN KEY (from_user_id) REFERENCES users (id),
  CONSTRAINT fk_likes_for_media_users_2 FOREIGN KEY (to_user_id) REFERENCES users (id)
);
-- Поставим лайк на медиафайл Пете от Васи.
INSERT INTO likes_for_media VALUES (1, 2, 1, 1);

SELECT * FROM likes_for_media;