CREATE TABLE migration_test (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

INSERT INTO migration_test (name) VALUES 
    ('Initial migration test data');