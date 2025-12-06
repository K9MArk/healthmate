PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS daily_record;
DROP TABLE IF EXISTS user_profile;

CREATE TABLE user_profile (
    username TEXT PRIMARY KEY,
    password TEXT NOT NULL,
    name TEXT NOT NULL,
    dob TEXT NOT NULL,
    height_cm INTEGER NOT NULL,
    weight_kg REAL NOT NULL,
    has_diabetes INTEGER NOT NULL,
    has_cholesterol INTEGER NOT NULL,
    profile_picture TEXT
);

CREATE TABLE daily_record (
    record_id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL,
    date TEXT NOT NULL,
    steps INTEGER NOT NULL,
    water_ml INTEGER NOT NULL,
    calorie_intake INTEGER NOT NULL,
    FOREIGN KEY (username) REFERENCES user_profile(username)
);

-- OPTIONAL SAMPLE DATA -------------------------

INSERT INTO user_profile (
    username, password, name, dob, height_cm, weight_kg,
    has_diabetes, has_cholesterol, profile_picture
) VALUES (
    'test123', '1234', 'Test User', '2000-01-01',
    170, 70, 0, 0, NULL
);

INSERT INTO daily_record (
    username, date, steps, water_ml, calorie_intake
) VALUES
('test123', '2025-12-07', 8500, 2000, 2100),
('test123', '2025-12-08', 6000, 1500, 1800);
