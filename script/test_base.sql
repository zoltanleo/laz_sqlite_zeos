--
-- Файл сгенерирован с помощью SQLiteStudio v3.4.4 в Вт авг 6 15:47:39 2024
--
-- Использованная кодировка текста: UTF-8
--
PRAGMA foreign_keys = off;
BEGIN TRANSACTION;

-- Таблица: PERSONALITY
DROP TABLE IF EXISTS PERSONALITY;

CREATE TABLE IF NOT EXISTS PERSONALITY (
    ID        INTEGER       PRIMARY KEY ASC ON CONFLICT ROLLBACK AUTOINCREMENT
                            NOT NULL,
    LASTNAME  VRACHAR (100) NOT NULL
                            DEFAULT NONAME_LASTNAME,
    FIRSTNAME VARCHAR (100) NOT NULL
                            DEFAULT NONAME_FIRSTNAME,
    THIRDNAME VARCHAR (100) DEFAULT NONAME_THIRDNAME,
    DATEBORN  DATETIME      NOT NULL
                            DEFAULT (CURRENT_TIMESTAMP),
    SEX       INTEGER       DEFAULT (1) 
                            NOT NULL
                            CHECK (SEX IN (0, 1) ) 
);


COMMIT TRANSACTION;
PRAGMA foreign_keys = on;
