1. Выбрать всех пользователей, у которых логины представляют два раза повторяющуюся последовательность символов.

SELECT *
FROM Users
WHERE LENGTH(Login) % 2 = 0
  AND LEFT(Login, LENGTH(Login) / 2) =
      RIGHT(Login, LENGTH(Login) / 2);

2. Выбрать пользователей, у которых есть хотя бы один персонаж, содержащий в своем имени никнейм.

SELECT DISTINCT u.*
FROM Users u
WHERE EXISTS (
    SELECT 1
    FROM Characters c
    WHERE c.User_ID = u.User_ID
      AND POSITION(LOWER(u.Nickname) IN LOWER(c.Character_Name)) > 0

3. Создать таблицу, содержащую данные 1 запроса с указанием информации о персонажах.

CREATE TABLE Users_Characters AS
SELECT
    u.User_ID,
    u.Email,
    u.Login,
    u.Password,
    u.Nickname,
    u.User_Level,
    c.Character_ID,
    c.Character_Name,
    c.Character_Story,
    c.Character_Level,
    c.Special_Skills
FROM Users u
LEFT JOIN Characters c
    ON u.User_ID = c.User_ID
WHERE LENGTH(u.Login) % 2 = 0
  AND LEFT(u.Login, LENGTH(u.Login) / 2) =
      RIGHT(u.Login, LENGTH(u.Login) / 2);

 4. Добавить в созданную таблицу пользователей, пароль которых содержит более пяти спецсимволов.

 INSERT INTO Users_Characters
SELECT
    u.User_ID,
    u.Email,
    u.Login,
    u.Password,
    u.Nickname,
    u.User_Level,
    c.Character_ID,
    c.Character_Name,
    c.Character_Story,
    c.Character_Level,
    c.Special_Skills
FROM Users u
LEFT JOIN Characters c
    ON u.User_ID = c.User_ID
WHERE LENGTH(
    REGEXP_REPLACE(u.Password, '[[:alnum:]]', '', 'g')
) > 5;

5. В созданной таблице у всех пользователей, имеющих персонажей выше 10 уровня, повысить собственный уровень на 2 пункта.

UPDATE Users_Characters
SET User_Level = User_Level + 2
WHERE User_ID IN (
    SELECT DISTINCT User_ID
    FROM Users_Characters
    WHERE Character_Level > 10
);

6. Удалить из созданной таблицы пользователей с некорректными адресами электронной почты.

DELETE FROM Users_Characters
WHERE Email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';

7. Посчитать количество персонажей и определить максимальный уровень среди персонажей для каждого пользователя.

SELECT
    u.User_ID,
    u.Nickname,
    COUNT(c.Character_ID) AS Character_Count,
    MAX(c.Character_Level) AS Max_Character_Level
FROM Users u
LEFT JOIN Characters c
    ON u.User_ID = c.User_ID
GROUP BY u.User_ID, u.Nickname
ORDER BY u.User_ID;