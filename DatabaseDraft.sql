CREATE TABLE IF NOT EXISTS users(
    user_id INT PRIMARY KEY,
    username VARCHAR(32),
    first_name VARCHAR(32),
    last_name VARCHAR(32),
    email VARCHAR(32),
    Salt_Value VARCHAR(16),
    HASHED_plus_SALTED_P VARCHAR(64),
    numSavedRecipes INT,
    prefID INT FOREIGN KEY REFERENCES user_pref_profile (pref_profile_id)
);

CREATE TABLE IF NOT EXISTS user_allergens(
    user_id INT,
    ingredient INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (ingredient) REFERENCES ingredients(ingredient_id),
);

CREATE TABLE IF NOT EXISTS user_saved_recipes(
    saved_recipe_id INT PRIMARY KEY,
    user_id INT FOREIGN KEY REFERENCES users(user_id),
    recipe_id INT FOREIGN KEY REFERENCES recipes (recipe_id)
);

CREATE TABLE IF NOT EXISTS user_pref_profile(
    pref_profile_id INT PRIMARY KEY,
    user_id INT FOREIGN KEY REFERENCES users(user_id),
    sweet_pref TINYINT(1),
    salty_pref TINYINT(1),
    sour_pref TINYINT(1),
    bitter_pref TINYINT(1),
    umami_pref TINYINT(1),
    heat_pref INT
);

CREATE TABLE IF NOT EXISTS recipes(
    recipe_id INT PRIMARY KEY,
    recipe_name VARCHAR(64),
    instructions VARCHAR(2048),
    author INT FOREIGN KEY REFERENCES users(user_id),
    overall_rating DECIMAL(1),
    num_ratings INT,
    num_likes INT,
    origin_country VARCHAR(45),
    description VARCHAR(1024),
    prep_time SMALLINT(4),
    cook_time SMALLINT(4),
    total_prep_time SMALLINT(4),
    yeild SMALLINT(4),
    flavor_id INT FOREIGN KEY REFERENCES recipe_flavor_breakdown(flavor_id),
    nutrition_index INT FOREIGN KEY REFERENCES recipeNutritionIndexs(recipe_nutrition_index_id),
    difficulty_level VARCHAR(16),
    meal VARCHAR(16),
    upload DATETIME
);

CREATE TABLE IF NOT EXISTS recipe_ingredients(
    recipe_ingredient_id INT PRIMARY KEY,
    recipe_id FOREIGN KEY REFERENCES recipes(recipe_id),
    ingredient_ID INT FOREIGN KEY REFERENCES ingredients(ingredient_id),
    ingredient_quality smallINT(4),
    measurementUnit VARCHAR(32)
);

CREATE TABLE IF NOT EXISTS recipe_tips(
    tip_id INT PRIMARY KEY,
    recipe_id INT FOREIGN KEY REFERENCES recipes(recipe_id),
    author INT FOREIGN KEY REFERENCES users(user_id),
    text VARCHAR(512),
    num_likes INT
);


CREATE TABLE IF NOT EXISTS  recipe_flavour_breakdown(
    flavor_id INT PRIMARY KEY,
    recipe INT FOREIGN KEY REFERENCES recipe(recipe_id),
    sweet_score TINYINT(1),  
    salty_score TINYINT(1), 
    sour_score TINYINT(1), 
    bitter_score TINYINT(1), 
    umami_score TINYINT(1),
    heat_score TINYINT(1), 
    
);

CREATE TABLE IF NOT EXISTS recipe_reviews(
    review_id INT PRIMARY KEY,
    recipe INT FOREIGN KEY REFERENCES recipes(recipe_id),
    author INT FOREIGN KEY REFERENCES users(user_id),
    rating DECIMAL(1),
    submissionDate DATETIME,
    review_text VARCHAR(2048),
    num_likes INT
);

CREATE TABLE IF NOT EXISTS ingredients(
    ingredient_id INT PRIMARY KEY,
    ingredientName VARCHAR(45),
    foodType VARCHAR(45),
    ingredient_nutrition_index INT FOREIGN KEY REFERENCES ingredientNutritionIndexes(ingredient_nutrition_index),
    sweet_score TINYINT(1),  
    salty_score TINYINT(1), 
    sour_score TINYINT(1), 
    bitter_score TINYINT(1), 
    umami_score TINYINT(1),
    spiciness TINYINT(1), 
);




CREATE TABLE IF NOT EXISTS pantry_items(
    pantry_item_id INT PRIMARY KEY,
    owner INT FOREIGN KEY REFERENCES users(user_id),
    ingredient INT FOREIGN KEY REFERENCES ingredients(ingredient_id),
    purchase_date DATETIME,
    knownExpirationDATE DATETIME,
    estimatedExpirationDate DATETIME
);

CREATE TABLE IF NOT EXISTS ingredientNutritionIndexes(
    ingredient_nutrition_index INT PRIMARY KEY,
    ingredient_id INT FOREIGN KEY REFERENCES ingredients(ingredient_id),
    servingSize SMALLINT(4),
    calories SMALLINT(4),
    totalFat SMALLINT(4),
    caloriesFromFat SMALLINT(4),
    saturatedFat SMALLINT(4),
    transFat SMALLINT(4),
    cholesterol SMALLINT(4),
    omega3s SMALLINT(4),
    sodium SMALLINT(4),,
    totalCarbs SMALLINT(4),
    dietartFiber SMALLINT(4),
    sugars SMALLINT(4),
    protien SMALLINT(4),
    vitamanA TINYINT(1),
    vitamanC TINYINT(1),
    calcium TINYINT(1),
    iron TINYINT(1),
    magnesium TINYINT(1),
    potassium TINYINT(1),,
    zinc TINYINT(1),
);


CREATE TABLE IF NOT EXISTS  recipeNutritionIndexes(
    recipe_nutrition_index INT PRIMARY KEY,
    recipe_id INT FOREIGN KEY REFERENCES recipes(recipe_id),
    servingSize SMALLINT(4),
    calories SMALLINT(4),
    totalFat SMALLINT(4),
    caloriesFromFat SMALLINT(4),
    saturatedFat SMALLINT(4),
    transFat SMALLINT(4),
    cholesterol SMALLINT(4),
    omega3s SMALLINT(4),
    sodium SMALLINT(4),,
    totalCarbs SMALLINT(4),
    dietartFiber SMALLINT(4),
    sugars SMALLINT(4),
    protien SMALLINT(4),
    vitamanA TINYINT(1),
    vitamanC TINYINT(1),
    calcium TINYINT(1),
    iron TINYINT(1),
    magnesium TINYINT(1),
    potassium TINYINT(1),,
    zinc TINYINT(1),
);
