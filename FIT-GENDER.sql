--CREATING Tables 

--USERS 
CREATE TABLE users (
    user_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) UNIQUE NOT NULL,
    password_hash VARCHAR2(255) NOT NULL,
    phone_number VARCHAR2(20),
    date_of_birth DATE,
    gender VARCHAR2(10),
    registration_date TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    account_status VARCHAR2(20) DEFAULT 'active'
);

--SUBSCRIPTION PLANS
CREATE TABLE subscription_plans (
    plan_id NUMBER PRIMARY KEY,
    plan_name VARCHAR2(50) NOT NULL,
    description VARCHAR2(500),
    monthly_price NUMBER(10,2) NOT NULL,
    annual_price NUMBER(10,2),
    max_trainer_sessions NUMBER,
    max_nutritionist_sessions NUMBER,
    features CLOB
);

--SUBSCRIPTIONS
CREATE TABLE subscriptions (
    subscription_id NUMBER PRIMARY KEY,
    user_id NUMBER NOT NULL,
    plan_id NUMBER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    auto_renewal NUMBER(1) DEFAULT 1,
    payment_status VARCHAR2(20) DEFAULT 'active',
    billing_cycle VARCHAR2(10) NOT NULL,
    CONSTRAINT fk_sub_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_sub_plan FOREIGN KEY (plan_id) REFERENCES subscription_plans(plan_id),
    CONSTRAINT chk_billing_cycle CHECK (billing_cycle IN ('monthly', 'annual'))
);

--TRAINERS
CREATE TABLE trainers (
    trainer_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) UNIQUE NOT NULL,
    phone_number VARCHAR2(20),
    certification_details CLOB NOT NULL,
    specialization VARCHAR2(100),
    hourly_rate NUMBER(10,2) NOT NULL,
    is_verified NUMBER(1) DEFAULT 0,
    join_date DATE DEFAULT SYSDATE,
    average_rating NUMBER(3,2)
);

--NUTRITIONISTS
CREATE TABLE nutritionists (
    nutritionist_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) UNIQUE NOT NULL,
    phone_number VARCHAR2(20),
    certification_details CLOB NOT NULL,
    specialization VARCHAR2(100),
    hourly_rate NUMBER(10,2) NOT NULL,
    is_verified NUMBER(1) DEFAULT 0,
    join_date DATE DEFAULT SYSDATE,
    average_rating NUMBER(3,2)
);

--EXERCISES
CREATE TABLE exercises (
    exercise_id NUMBER PRIMARY KEY,
    exercise_name VARCHAR2(100) NOT NULL,
    muscle_group_targeted VARCHAR2(50) NOT NULL,
    equipment_required VARCHAR2(100),
    difficulty_level VARCHAR2(20),
    description VARCHAR2(500),
    video_demo_url VARCHAR2(255)
);
--MEALS
CREATE TABLE meals (
    meal_id NUMBER PRIMARY KEY,
    meal_name VARCHAR2(100) NOT NULL,
    calories_per_serving NUMBER,
    protein_grams NUMBER(10,2),
    carbs_grams NUMBER(10,2),
    fats_grams NUMBER(10,2),
    preparation_time_minutes NUMBER,
    ingredients_list CLOB,
    recipe_instructions CLOB
);
--WORKOUT PLANS
CREATE TABLE workout_plans (
    workout_plan_id NUMBER PRIMARY KEY,
    trainer_id NUMBER NOT NULL,
    plan_name VARCHAR2(100) NOT NULL,
    difficulty_level VARCHAR2(20) NOT NULL,
    creation_date DATE DEFAULT SYSDATE,
    last_updated_date DATE,
    description VARCHAR2(500),
    estimated_duration_weeks NUMBER,
    CONSTRAINT fk_wp_trainer FOREIGN KEY (trainer_id) REFERENCES trainers(trainer_id)
);
--NUTRITION PLANS
CREATE TABLE nutrition_plans (
    nutrition_plan_id NUMBER PRIMARY KEY,
    nutritionist_id NUMBER NOT NULL,
    plan_name VARCHAR2(100) NOT NULL,
    dietary_preference VARCHAR2(50) NOT NULL,
    creation_date DATE DEFAULT SYSDATE,
    last_updated_date DATE,
    description VARCHAR2(500),
    estimated_duration_weeks NUMBER,
    CONSTRAINT fk_np_nutritionist FOREIGN KEY (nutritionist_id) REFERENCES nutritionists(nutritionist_id)
);
--SESSIONS
CREATE TABLE sessions (
    session_id NUMBER PRIMARY KEY,
    user_id NUMBER NOT NULL,
    trainer_id NUMBER,
    nutritionist_id NUMBER,
    professional_type VARCHAR2(20) NOT NULL,
    scheduled_date_time TIMESTAMP NOT NULL,
    duration_minutes NUMBER NOT NULL,
    status VARCHAR2(20) DEFAULT 'scheduled',
    session_notes CLOB,
    feedback_submitted NUMBER(1) DEFAULT 0,
    CONSTRAINT fk_session_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_session_trainer FOREIGN KEY (trainer_id) REFERENCES trainers(trainer_id),
    CONSTRAINT fk_session_nutritionist FOREIGN KEY (nutritionist_id) REFERENCES nutritionists(nutritionist_id),
    CONSTRAINT chk_professional_type CHECK (professional_type IN ('trainer', 'nutritionist'))
);

--PROGRESS TRACKING

CREATE TABLE progress_tracking (
    tracking_id NUMBER PRIMARY KEY,
    user_id NUMBER NOT NULL,
    tracking_date DATE DEFAULT SYSDATE NOT NULL,
    weight_kg NUMBER(10,2),
    body_fat_percentage NUMBER(10,2),
    muscle_mass_kg NUMBER(10,2),
    waist_circumference_cm NUMBER(10,2),
    hip_circumference_cm NUMBER(10,2),
    notes VARCHAR2(500),
    CONSTRAINT fk_pt_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT chk_metrics CHECK (
        weight_kg IS NOT NULL OR
        body_fat_percentage IS NOT NULL OR
        muscle_mass_kg IS NOT NULL OR
        waist_circumference_cm IS NOT NULL
    )
);

--COMMUNITY POSTS
CREATE TABLE community_posts (
    post_id NUMBER PRIMARY KEY,
    user_id NUMBER NOT NULL,
    post_title VARCHAR2(200) NOT NULL,
    post_content CLOB NOT NULL,
    post_date TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    like_count NUMBER DEFAULT 0,
    is_pinned NUMBER(1) DEFAULT 0,
    status VARCHAR2(20) DEFAULT 'active',
    CONSTRAINT fk_cp_user FOREIGN KEY (user_id) REFERENCES users(user_id)
);

--COMMENTS
CREATE TABLE comments (
    comment_id NUMBER PRIMARY KEY,
    post_id NUMBER NOT NULL,
    user_id NUMBER NOT NULL,
    comment_content VARCHAR2(1000) NOT NULL,
    comment_date TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    like_count NUMBER DEFAULT 0,
    status VARCHAR2(20) DEFAULT 'active',
    CONSTRAINT fk_comment_post FOREIGN KEY (post_id) REFERENCES community_posts(post_id),
    CONSTRAINT fk_comment_user FOREIGN KEY (user_id) REFERENCES users(user_id)
);

--PRODUCTS
CREATE TABLE products (
    product_id NUMBER PRIMARY KEY,
    product_name VARCHAR2(100) NOT NULL,
    product_description VARCHAR2(500),
    category VARCHAR2(50) NOT NULL,
    price NUMBER(10,2) NOT NULL,
    stock_quantity NUMBER DEFAULT 0,
    image_url VARCHAR2(255),
    average_rating NUMBER(3,2)
);
--ORDERS
CREATE TABLE orders (
    order_id NUMBER PRIMARY KEY,
    user_id NUMBER NOT NULL,
    order_date TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    total_amount NUMBER(10,2) NOT NULL,
    shipping_address VARCHAR2(500),
    order_status VARCHAR2(20) DEFAULT 'processing',
    payment_method VARCHAR2(50) NOT NULL,
    CONSTRAINT fk_order_user FOREIGN KEY (user_id) REFERENCES users(user_id)
);
--PAYMENTS
CREATE TABLE payments (
    payment_id NUMBER PRIMARY KEY,
    order_id NUMBER,
    subscription_id NUMBER,
    payment_amount NUMBER(10,2) NOT NULL,
    payment_date TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    payment_method VARCHAR2(50) NOT NULL,
    transaction_status VARCHAR2(20) NOT NULL,
    receipt_url VARCHAR2(255),
    CONSTRAINT fk_payment_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_payment_sub FOREIGN KEY (subscription_id) REFERENCES subscriptions(subscription_id),
    CONSTRAINT chk_payment_reference CHECK (
        (order_id IS NOT NULL AND subscription_id IS NULL) OR
        (order_id IS NULL AND subscription_id IS NOT NULL)
    )
);
--USER WORKOUT PLANS
CREATE TABLE user_workout_plans (
    user_id NUMBER NOT NULL,
    workout_plan_id NUMBER NOT NULL,
    assignment_date DATE DEFAULT SYSDATE NOT NULL,
    completion_status VARCHAR2(20) DEFAULT 'active',
    PRIMARY KEY (user_id, workout_plan_id),
    CONSTRAINT fk_uwp_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_uwp_plan FOREIGN KEY (workout_plan_id) REFERENCES workout_plans(workout_plan_id)
);

--USER NUTRITION PLANS
CREATE TABLE user_nutrition_plans (
    user_id NUMBER NOT NULL,
    nutrition_plan_id NUMBER NOT NULL,
    assignment_date DATE DEFAULT SYSDATE NOT NULL,
    completion_status VARCHAR2(20) DEFAULT 'active',
    PRIMARY KEY (user_id, nutrition_plan_id),
    CONSTRAINT fk_unp_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_unp_plan FOREIGN KEY (nutrition_plan_id) REFERENCES nutrition_plans(nutrition_plan_id)
);

--WOKOUT PLANS EXERCISES
CREATE TABLE workout_plan_exercises (
    workout_plan_id NUMBER NOT NULL,
    exercise_id NUMBER NOT NULL,
    day_number NUMBER NOT NULL,
    sets NUMBER,
    reps NUMBER,
    rest_seconds NUMBER,
    PRIMARY KEY (workout_plan_id, exercise_id, day_number),
    CONSTRAINT fk_wpe_plan FOREIGN KEY (workout_plan_id) REFERENCES workout_plans(workout_plan_id),
    CONSTRAINT fk_wpe_exercise FOREIGN KEY (exercise_id) REFERENCES exercises(exercise_id)
);

--NUTRITION PLAN MEALS
CREATE TABLE nutrition_plan_meals (
    nutrition_plan_id NUMBER NOT NULL,
    meal_id NUMBER NOT NULL,
    meal_type VARCHAR2(20) NOT NULL,
    day_of_week NUMBER NOT NULL,
    serving_size VARCHAR2(50),
    PRIMARY KEY (nutrition_plan_id, meal_id, day_of_week),
    CONSTRAINT fk_npm_plan FOREIGN KEY (nutrition_plan_id) REFERENCES nutrition_plans(nutrition_plan_id),
    CONSTRAINT fk_npm_meal FOREIGN KEY (meal_id) REFERENCES meals(meal_id)
);

--ORDER PRODUCTS
CREATE TABLE order_products (
    order_id NUMBER NOT NULL,
    product_id NUMBER NOT NULL,
    quantity NUMBER NOT NULL,
    unit_price_at_purchase NUMBER(10,2) NOT NULL,
    PRIMARY KEY (order_id, product_id),
    CONSTRAINT fk_op_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_op_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);

--EXTRA FUNTIONALITY
-- Attendance Tracking
CREATE TABLE class_attendance (
    attendance_id NUMBER PRIMARY KEY,
    session_id NUMBER NOT NULL,
    user_id NUMBER NOT NULL,
    attendance_date DATE DEFAULT SYSDATE,
    status VARCHAR2(10) CHECK (status IN ('present', 'absent', 'late')),
    CONSTRAINT fk_attendance_session FOREIGN KEY (session_id) REFERENCES sessions(session_id),
    CONSTRAINT fk_attendance_user FOREIGN KEY (user_id) REFERENCES users(user_id)
);
-- Group Classes Management
CREATE TABLE group_classes (
    class_id NUMBER PRIMARY KEY,
    trainer_id NUMBER NOT NULL,
    class_name VARCHAR2(50) NOT NULL,
    schedule VARCHAR2(100),
    max_participants NUMBER,
    CONSTRAINT fk_class_trainer FOREIGN KEY (trainer_id) REFERENCES trainers(trainer_id)
);
--Insert STATEMENTS--

-- Users
INSERT INTO users (user_id, first_name, last_name, email, password_hash, phone_number, date_of_birth, gender) 
VALUES (1, 'John', 'Doe', 'john.doe@example.com', '5f4dc', '1234567890', TO_DATE('1990-01-15', 'YYYY-MM-DD'), 'male');

-- Subscription Plans
INSERT INTO subscription_plans (plan_id, plan_name, description, monthly_price, annual_price, max_trainer_sessions, max_nutritionist_sessions) 
VALUES (1, 'Premium', 'Full access to all features', 49.99, 499.99, 8, 4);

-- Subscriptions
INSERT INTO subscriptions (subscription_id, user_id, plan_id, start_date, end_date, billing_cycle) 
VALUES (1, 1, 1, TO_DATE('2023-01-01', 'YYYY-MM-DD'), TO_DATE('2024-01-01', 'YYYY-MM-DD'), 'annual');

-- Trainers
INSERT INTO trainers (trainer_id, first_name, last_name, email, certification_details, specialization, hourly_rate) 
VALUES (1, 'Mike', 'Johnson', 'mike.johnson@example.com', 'NASM Certified Personal Trainer', 'Strength Training', 75.00);

-- Nutritionists
INSERT INTO nutritionists (nutritionist_id, first_name, last_name, email, certification_details, specialization, hourly_rate) 
VALUES (1, 'Sarah', 'Williams', 'sarah.williams@example.com', 'Registered Dietitian Nutritionist', 'Weight Management', 85.00);

-- Exercises
INSERT INTO exercises (exercise_id, exercise_name, muscle_group_targeted, difficulty_level, description) 
VALUES (1, 'Barbell Squat', 'Legs', 'Intermediate', 'Compound exercise targeting quadriceps, hamstrings, and glutes');

-- Meals
INSERT INTO meals (meal_id, meal_name, calories_per_serving, protein_grams, carbs_grams, fats_grams) 
VALUES (1, 'Grilled Chicken with Quinoa', 450, 35, 40, 12);

-- Workout Plans
INSERT INTO workout_plans (workout_plan_id, trainer_id, plan_name, difficulty_level, description) 
VALUES (1, 1, 'Beginner Strength Program', 'Beginner', '12-week strength training program for beginners');

-- Nutrition Plans
INSERT INTO nutrition_plans (nutrition_plan_id, nutritionist_id, plan_name, dietary_preference, description) 
VALUES (1, 1, 'Balanced Weight Loss', 'Balanced', '12-week nutrition plan for healthy weight loss');

-- Sessions
INSERT INTO sessions (session_id, user_id, trainer_id, professional_type, scheduled_date_time, duration_minutes) 
VALUES (1, 1, 1, 'trainer', TO_TIMESTAMP('2023-06-15 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), 60);

-- Progress Tracking
INSERT INTO progress_tracking (tracking_id, user_id, weight_kg, body_fat_percentage) 
VALUES (1, 1, 80.5, 18.2);

-- Community Posts
INSERT INTO community_posts (post_id, user_id, post_title, post_content) 
VALUES (1, 1, 'My fitness journey', 'Sharing my 6-month transformation story');

-- Comments
INSERT INTO comments (comment_id, post_id, user_id, comment_content) 
VALUES (1, 1, 1, 'Great progress! Keep it up!');

-- Products
INSERT INTO products (product_id, product_name, category, price, stock_quantity) 
VALUES (1, 'Protein Powder', 'Supplements', 29.99, 100);

-- Orders
INSERT INTO orders (order_id, user_id, total_amount, payment_method) 
VALUES (1, 1, 59.98, 'credit_card');

-- Payments
INSERT INTO payments (payment_id, order_id, payment_amount, payment_method, transaction_status) 
VALUES (1, 1, 59.98, 'credit_card', 'completed');

-- User Workout Plans
INSERT INTO user_workout_plans (user_id, workout_plan_id) 
VALUES (1, 1);

-- User Nutrition Plans
INSERT INTO user_nutrition_plans (user_id, nutrition_plan_id) 
VALUES (1, 1);

-- Workout Plan Exercises
INSERT INTO workout_plan_exercises (workout_plan_id, exercise_id, day_number, sets, reps) 
VALUES (1, 1, 1, 3, 10);

-- Nutrition Plan Meals
INSERT INTO nutrition_plan_meals (nutrition_plan_id, meal_id, meal_type, day_of_week) 
VALUES (1, 1, 'lunch', 1);

-- Order Products
INSERT INTO order_products (order_id, product_id, quantity, unit_price_at_purchase) 
VALUES (1, 1, 2, 29.99);

--Group classes
-- Insert a group class (prerequisite for attendance)
INSERT INTO group_classes 
VALUES (1, 1, 'Morning Yoga', 'Mon/Wed/Fri 7-8AM', 15);

--Class Attendance

-- Insert attendance record
INSERT INTO class_attendance 
VALUES (100, 1, 1, SYSDATE, 'present');

