CREATE TYPE status_type AS ENUM ('approved', 'pending', 'rejected');

CREATE TABLE role (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE app_user (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    date_of_birth DATE,
    profile_picture_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_role (
    user_id INTEGER REFERENCES app_user(id) ON DELETE CASCADE,
    role_id INTEGER REFERENCES role(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

CREATE TABLE client_trainer (
    client_id INTEGER REFERENCES app_user(id) ON DELETE CASCADE,
    trainer_id INTEGER REFERENCES app_user(id) ON DELETE CASCADE,
    start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status status_type DEFAULT 'pending',
    end_date TIMESTAMP,
    PRIMARY KEY (client_id, trainer_id)
);

CREATE TABLE muscular_group (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE exercise (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER REFERENCES app_user(id) ON DELETE SET NULL
);

CREATE TABLE exercise_muscular_group (
    exercise_id INTEGER REFERENCES exercise(id) ON DELETE CASCADE,
    muscular_group_id INTEGER REFERENCES muscular_group(id) ON DELETE CASCADE,
    priority INTEGER NOT NULL,
    PRIMARY KEY (exercise_id, muscular_group_id)
);

CREATE TABLE workout (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    trainer_id INTEGER NOT NULL REFERENCES app_user(id),
    is_public BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE workout_exercise (
    id SERIAL PRIMARY KEY,
    workout_id INTEGER NOT NULL REFERENCES workout(id) ON DELETE CASCADE,
    exercise_id INTEGER NOT NULL REFERENCES exercise(id) ON DELETE CASCADE,
    order_number INTEGER NOT NULL,
    rest_time INTEGER,
    notes TEXT
);

CREATE TABLE workout_exercise_set (
    id SERIAL PRIMARY KEY,
    workout_exercise_id INTEGER NOT NULL REFERENCES workout_exercise(id),
    order_number INTEGER NOT NULL,
    repetitions INTEGER,
    weight_used DOUBLE PRECISION
);

CREATE TABLE workout_assignment (
    id SERIAL PRIMARY KEY,
    workout_id INTEGER NOT NULL REFERENCES workout(id) ON DELETE CASCADE,
    client_id INTEGER NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    assigned_by INTEGER NOT NULL REFERENCES app_user(id),
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    start_date DATE NOT NULL,
    end_date DATE,
    is_active BOOLEAN DEFAULT true,
    notes TEXT
);

CREATE TABLE workout_schedule (
    id SERIAL PRIMARY KEY,
    workout_assignment_id INTEGER NOT NULL REFERENCES workout_assignment(id) ON DELETE CASCADE,
    day_of_week INTEGER CHECK (day_of_week BETWEEN 0 AND 6),
    is_active BOOLEAN DEFAULT true
);

CREATE TABLE workout_record (
    id SERIAL PRIMARY KEY,
    workout_assignment_id INTEGER NOT NULL REFERENCES workout_assignment(id) ON DELETE CASCADE,
    client_id INTEGER NOT NULL REFERENCES app_user(id),
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    duration_minutes INTEGER,
    notes TEXT
);

CREATE TABLE exercise_record (
    id SERIAL PRIMARY KEY,
    workout_record_id INTEGER NOT NULL REFERENCES workout_record(id) ON DELETE CASCADE,
    exercise_id INTEGER NOT NULL REFERENCES exercise(id),
    rest_time INTEGER,
    notes TEXT
);

CREATE TABLE set_record (
    id SERIAL PRIMARY KEY,
    exercise_record_id INTEGER NOT NULL REFERENCES exercise_record(id) ON DELETE CASCADE,
    repetitions INTEGER,
    weight_used DOUBLE PRECISION
);

CREATE INDEX idx_user_role_user_id ON user_role(user_id);
CREATE INDEX idx_user_role_role_id ON user_role(role_id);
CREATE INDEX idx_workout_trainer_id ON workout(trainer_id);
CREATE INDEX idx_workout_exercise_workout_id ON workout_exercise(workout_id);
CREATE INDEX idx_workout_exercise_set_workout_exercise_id ON workout_exercise_set(workout_exercise_id);
CREATE INDEX idx_workout_assignment_client_id ON workout_assignment(client_id);
CREATE INDEX idx_workout_assignment_workout_id ON workout_assignment(workout_id);
CREATE INDEX idx_workout_schedule_assignment_id ON workout_schedule(workout_assignment_id);
CREATE INDEX idx_workout_record_client_id ON workout_record(client_id);
CREATE INDEX idx_workout_record_assignment_id ON workout_record(workout_assignment_id);
CREATE INDEX idx_exercise_record_workout_record_id ON exercise_record(workout_record_id);
CREATE INDEX idx_exercise_record_exercise_id ON exercise_record(exercise_id);
CREATE INDEX idx_set_record_exercise_record_id ON set_record(exercise_record_id);
CREATE INDEX idx_client_trainer_status ON client_trainer(status);

ALTER TABLE client_trainer ADD CONSTRAINT check_different_users 
    CHECK (client_id != trainer_id);

ALTER TABLE workout_assignment ADD CONSTRAINT check_start_end_date 
    CHECK (end_date IS NULL OR start_date <= end_date);