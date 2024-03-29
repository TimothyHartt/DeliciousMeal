CREATE DATABASE IF NOT EXISTS deliciousMeal;
USE deliciousMeal;

CREATE TABLE IF NOT EXISTS preferenceProfiles(
    preferenceProfileID INT PRIMARY KEY AUTO_INCREMENT,
    userIndex INT NOT NULL,
    sweetPref TINYINT(1) DEFAULT 0,
    saltyPref TINYINT(1) DEFAULT 0,
    sourPref TINYINT(1) DEFAULT 0,
    bitterPref TINYINT(1) DEFAULT 0,
    umamiPref TINYINT(1) DEFAULT 0,
    heatPref INT DEFAULT 0
);

CREATE TABLE IF NOT EXISTS users(
    userID INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(32) NOT NULL,
    firstName VARCHAR(32),
    lastName VARCHAR(32),
    email VARCHAR(32) NOT NULL,
    salt VARCHAR(16) NOT NULL,
    hashedPassword VARCHAR(64) NOT NULL,
    numSavedRecipes INT DEFAULT 0,
    preferenceProfile INT
);

CREATE TABLE IF NOT EXISTS ingredientNutritionIndexes(
    ingredientNutritionID INT PRIMARY KEY AUTO_INCREMENT,
    ingredient INT NOT NULL,
    servingSize SMALLINT(4),
    calories SMALLINT(4),
    totalFat SMALLINT(4),
    caloriesFromFat SMALLINT(4),
    saturatedFat SMALLINT(4),
    transFat SMALLINT(4),
    cholesterol SMALLINT(4),
    omega3s SMALLINT(4),
    sodium SMALLINT(4),
    totalCarbs SMALLINT(4),
    dietaryFiber SMALLINT(4),
    sugars SMALLINT(4),
    protein SMALLINT(4),
    vitaminA TINYINT(1),
    vitaminC TINYINT(1),
    calcium TINYINT(1),
    iron TINYINT(1),
    magnesium TINYINT(1),
    potassium TINYINT(1),
    zinc TINYINT(1)
);

CREATE TABLE IF NOT EXISTS ingredients(
    ingredientID INT PRIMARY KEY AUTO_INCREMENT,
    ingredientName VARCHAR(45) NOT NULL,
    foodType VARCHAR(45),
    ingredientNutritionIndex INT,
    sweetScore TINYINT(1) DEFAULT 0,
    saltyScore TINYINT(1) DEFAULT 0,
    sourScore TINYINT(1) DEFAULT 0,
    bitterScore TINYINT(1) DEFAULT 0,
    umamiScore TINYINT(1) DEFAULT 0,
    spiciness TINYINT(1) DEFAULT 0
);

CREATE TABLE IF NOT EXISTS allergens(
    userIndex INT NOT NULL,
    ingredient INT NOT NULL,
    PRIMARY KEY (userIndex, ingredient)
);

CREATE TABLE IF NOT EXISTS recipeFlavorBreakdowns(
    flavorBreakdownID INT PRIMARY KEY AUTO_INCREMENT,
    recipe INT NOT NULL,
    sweetScore TINYINT(1) DEFAULT 0,
    saltyScore TINYINT(1) DEFAULT 0,
    sourScore TINYINT(1) DEFAULT 0,
    bitterScore TINYINT(1) DEFAULT 0,
    umamiScore TINYINT(1) DEFAULT 0,
    heatScore TINYINT(1) DEFAULT 0
);

CREATE TABLE IF NOT EXISTS  recipeNutritionIndexes(
    recipeNutritionID INT PRIMARY KEY AUTO_INCREMENT,
    recipe INT NOT NULL,
    servingSize SMALLINT(4),
    calories SMALLINT(4),
    totalFat SMALLINT(4),
    caloriesFromFat SMALLINT(4),
    saturatedFat SMALLINT(4),
    transFat SMALLINT(4),
    cholesterol SMALLINT(4),
    omega3s SMALLINT(4),
    sodium SMALLINT(4),
    totalCarbs SMALLINT(4),
    dietaryFiber SMALLINT(4),
    sugars SMALLINT(4),
    protein SMALLINT(4),
    vitaminA TINYINT(1),
    vitaminC TINYINT(1),
    calcium TINYINT(1),
    iron TINYINT(1),
    magnesium TINYINT(1),
    potassium TINYINT(1),
    zinc TINYINT(1)
);

CREATE TABLE IF NOT EXISTS recipes(
    recipeID INT PRIMARY KEY AUTO_INCREMENT,
    recipeName VARCHAR(64) NOT NULL,
    instructions VARCHAR(2048) NOT NULL,
    rating DOUBLE,
    author INT,
    numRatings INT DEFAULT 0,
    numLikes INT DEFAULT 0,
    countryOfOrigin VARCHAR(45),
    descriptionText VARCHAR(1024),
    prepTime SMALLINT(4),
    cookTime SMALLINT(4),
    totalTime SMALLINT(4),
    yield SMALLINT(4),
    flavorBreakdown INT,
    recipeNutritionIndex INT,
    difficulty VARCHAR(16),
    meal VARCHAR(16),
    uploadDate DATETIME
);

CREATE TABLE IF NOT EXISTS savedRecipes(
    savedRecipeID INT PRIMARY KEY AUTO_INCREMENT,
    userIndex INT NOT NULL,
    recipe INT NOT NULL
);

CREATE TABLE IF NOT EXISTS recipeIngredients(
    recipeIngredientID INT PRIMARY KEY AUTO_INCREMENT,
    recipe INT NOT NULL,
    ingredient INT NOT NULL,
    quantity DOUBLE,
    measurementUnit VARCHAR(32)
);

CREATE TABLE IF NOT EXISTS tips(
    tipID INT PRIMARY KEY AUTO_INCREMENT,
    recipe INT NOT NULL,
    author INT,
    tipText VARCHAR(512) NOT NULL,
    numLikes INT DEFAULT 0
);

CREATE TABLE IF NOT EXISTS reviews(
    reviewID INT PRIMARY KEY AUTO_INCREMENT,
    recipe INT NOT NULL,
    author INT,
    rating DOUBLE,
    submissionDate DATETIME,
    reviewText VARCHAR(2048),
    numLikes INT DEFAULT 0
);

CREATE TABLE IF NOT EXISTS pantryItems(
    pantryItemID INT PRIMARY KEY AUTO_INCREMENT,
    ownerIndex INT NOT NULL,
    ingredient INT NOT NULL,
    purchaseDate DATETIME,
    knownExpirationDate DATETIME,
    estimatedExpirationDate DATETIME
);

//Stores an image
ALTER TABLE recipes
ADD COLUMN image BLOB

-- Add foreign key constraints after all tables are created to avoid conflicts
-- This is necessary because every table has at least one dependency pointing to another table
-- If we add foreign key definitions in the CREATE TABLE statement, we almost always reference a table that doesn't exist yet, which causes an error
-- By doing it at the end we guarentee every table exists already and can be referenced

ALTER TABLE preferenceProfiles
ADD FOREIGN KEY (userIndex) REFERENCES users(userID);

ALTER TABLE users
ADD FOREIGN KEY (preferenceProfile) REFERENCES preferenceProfiles(preferenceProfileID);

ALTER TABLE ingredientNutritionIndexes
ADD FOREIGN KEY (ingredient) REFERENCES ingredients(ingredientID);

ALTER TABLE ingredients
ADD FOREIGN KEY (ingredientNutritionIndex) REFERENCES ingredientNutritionIndexes(ingredientNutritionID);

ALTER TABLE allergens
ADD FOREIGN KEY (userIndex) REFERENCES users(userID),
ADD FOREIGN KEY (ingredient) REFERENCES ingredients(ingredientID);

ALTER TABLE recipeFlavorBreakdowns
ADD FOREIGN KEY (recipe) REFERENCES recipes(recipeID);

ALTER TABLE recipeNutritionIndexes
ADD FOREIGN KEY (recipe) REFERENCES recipes(recipeID);

ALTER TABLE recipes
ADD FOREIGN KEY (author) REFERENCES users(userID),
ADD FOREIGN KEY (flavorBreakdown) REFERENCES recipeFlavorBreakdowns(flavorBreakdownID),
ADD FOREIGN KEY (recipeNutritionIndex) REFERENCES recipeNutritionIndexes(recipeNutritionID);

ALTER TABLE savedRecipes
ADD FOREIGN KEY (userIndex) REFERENCES users(userID),
ADD FOREIGN KEY (recipe) REFERENCES recipes(recipeID);

ALTER TABLE recipeIngredients
ADD FOREIGN KEY (recipe) REFERENCES recipes(recipeID),
ADD FOREIGN KEY (ingredient) REFERENCES ingredients(ingredientID);

ALTER TABLE tips
ADD FOREIGN KEY (recipe) REFERENCES recipes(recipeID),
ADD FOREIGN KEY (author) REFERENCES users(userID);

ALTER TABLE reviews
ADD FOREIGN KEY (recipe) REFERENCES recipes(recipeID),
ADD FOREIGN KEY (author) REFERENCES users(userID);

ALTER TABLE pantryItems
ADD FOREIGN KEY (ownerIndex) REFERENCES users(userID),
ADD FOREIGN KEY (ingredient) REFERENCES ingredients(ingredientID);

-- Add some fake users to the database for testing
-- Each has a password of 'password'
INSERT INTO users (username, firstName, lastName, email, salt, hashedPassword)
VALUES ('alicea', 'Alice', 'A', 'alicea@email.com', 'XHh7VL6vxqTOMJCX', 'f77c83a9b2c71c0608d07716738d76822e5e44f7883b145af12c4364127c7c6e');

INSERT INTO users (username, firstName, lastName, email, salt, hashedPassword)
VALUES ('bobb', 'Bob', 'B', 'bobb@email.com', 'dZkUKLeOavB3s8Cp', 'e657873f94c46cff7d0563765f84d6083b7d56a5becaff4157b12a8ae601a42e');

INSERT INTO users (username, firstName, lastName, email, salt, hashedPassword)
VALUES ('charliec', 'Charlie', 'C', 'charliec@email.com', 'LuwBUkuFe7M24OK2', '3131757fe4961b7dc974e489d690385065aa9335b464b60c7c0cdc134478a46c');

INSERT INTO users (username, firstName, lastName, email, salt, hashedPassword)
VALUES ('davidd', 'David', 'D', 'davidd@email.com', 'cR4rVr7bzrV3bYkG', '48e0c06eaaaa4052dfad1e67ee3dde9cf3f9af47b3ebea80ea48cb7b181cb0c5');

INSERT INTO users (username, firstName, lastName, email, salt, hashedPassword)
VALUES ('edwarde', 'Edward', 'E', 'edwarde@email.com', 'O8AMlyp8qGPBetrH', '53c5e3dcd43b3064fec1025b6fe03c4a9d31664c171a7d0859d873019797ef18');

-- Add some ingredients (PLEASE ADD TO THIS!!!)

-- Example ingredient -> all scores are 0-100 and add up to 100
INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, umamiScore, spiciness)
VALUES ('banana', 'fruit', 95, 0, 0, 5, 0);

INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, umamiScore, spiciness)
VALUES ('mango', 'fruit', 90, 0, 3, 6, 0);

INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, umamiScore, spiciness)
VALUES ('apple', 'fruit', 90, 0, 0, 6, 0);

INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, umamiScore, spiciness)
VALUES ('orange', 'fruit', 90, 0, 10, 6, 0);

INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, umamiScore, spiciness)
VALUES ('strawberry', 'fruit', 90, 0, 4, 6, 0);

INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, umamiScore, spiciness)
VALUES ('blueberry', 'fruit', 68, 0, 13, 6, 0);

INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, umamiScore, spiciness)
VALUES ('rasberry', 'fruit', 65, 0, 4, 6, 0);

INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, umamiScore, spiciness)
VALUES ('blackberry', 'fruit', 70, 0, 7, 6, 0);

INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, umamiScore, spiciness)
VALUES ('pineapple', 'fruit', 90, 0, 10, 6, 0);

INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, umamiScore, spiciness)
VALUES ('peach', 'fruit', 85, 0, 0, 6, 0);

INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, umamiScore, spiciness)
VALUES ('red peppers', 'vegetable', 5, 20, 5, 0, 20);

INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, umamiScore, spiciness)
VALUES ('green peppers', 'vegetable', 4, 25, 5, 0, 20);

INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, umamiScore, spiciness)
VALUES ('yellow peppers', 'vegetable', 5, 20, 0, 0, 15);

INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, umamiScore, spiciness)
VALUES ('asparagus', 'vegetable', 0, 20, 0, 0, 0);

INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, umamiScore, spiciness)
VALUES ('potato', 'vegetable', 0, 18, 4, 0, 0);

INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, umamiScore, spiciness)
VALUES ('brocolli', 'vegetable', 3, 9, 0, 0, 0);

INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, umamiScore, spiciness)
VALUES ('corn', 'vegetable', 5, 20, 5, 0, 0);

INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, umamiScore, spiciness)
VALUES ('tomato', 'vegetable', 46, 16, 5, 0, 0);

INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, umamiScore, spiciness)
VALUES ('chicken', 'protien', 0, 10, 0, 5, 0);

INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, umamiScore, spiciness)
VALUES ('ham', 'protien', 0, 10, 0, 5, 0);

INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, umamiScore, spiciness)
VALUES ('beef', 'protien', 0, 20, 0, 5, 0);

INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, umamiScore, spiciness)
VALUES ('goat', 'protien', 0, 20, 0, 5, 0);

INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, umamiScore, spiciness)
VALUES ('egg', 'protien', 0, 5, 0, 5, 0);

INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, umamiScore, spiciness)
VALUES ('white rice', 'grain', 0, 0, 0, 5, 0);

INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, umamiScore, spiciness)
VALUES ('quoina', 'grain', 0, 10, 0, 5, 0);

INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, umamiScore, spiciness)
VALUES ('cheddar cheese', 'dairy', 0, 70, 0, 5, 0);

INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, umamiScore, spiciness)
VALUES ('pepperjack cheese', 'dairy', 0, 70, 0, 5, 45);

INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, umamiScore, spiciness)
VALUES ('american cheese', 'dairy', 0, 65, 0, 5, 0);

INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, umamiScore, spiciness)
VALUES ('2% milk', 'dairy', 10, 0, 0, 5, 0);

INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, umamiScore, spiciness)
VALUES ('whole milk', 'dairy', 15, 0, 0, 5, 0);

INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, umamiScore, spiciness)
VALUES ('almond milk', 'dairy', 35, 0, 0, 5, 0);

INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, umamiScore, spiciness)
VALUES ('soy milk', 'dairy', 35, 0, 0, 5, 0);

-- Example ingredient nutrition index
-- Serving size is in grams, all vitamins/minerals are daily intake percentages (i.e. 10 = 10% of recommended daily intake), everything else except calories are in grams or micrograms

INSERT INTO ingredientnutritionindexes (ingredient, servingSize, calories, totalFat, caloriesFromFat, saturatedFat, transFat, cholesterol, omega3s, sodium, totalCarbs, dietaryFiber, sugars, protein, vitaminA, vitaminC, calcium, iron, magnesium, potassium, zinc)
VALUES (1, 126, 112, 0.4, 3.5, 0.1, 0, 0, 34, 1.3, 28.8, 3.3, 15.4, 1.4, 2, 18, 1, 2, 9, 13, 1);

-- ADD RECIPES
INSERT INTO recipes (recipeID, recipeName, instructions, author, descriptionText, prepTime, cookTime, yield, difficulty, meal, uploadDate)
VALUES (40, 'Mac N Cheese', 'Bring water to boil in medium saucepan. Add Macaroni; cook 7 to 8 min. or until tender, stirring occasionally. Drain. (Do not rinse.) Return macaroni to pan. Add margarine, milk and Cheese Sauce Mix; mix well.', 4, 'Discover an easy three-step recipe for making your favorite Macaroni & Cheese Dinner!', 8, 7, 3, 'easy', 'dinner', SYSDATE());

INSERT INTO recipes (recipeID, recipeName, instructions, author, descriptionText, prepTime, cookTime, yield, difficulty, meal, uploadDate)
VALUES (41, 'Waffles', 'Buy eggo waffles. Put waffles in toaster and wait. Add anything extra', 4, 'Delicious waffles ready in minutes.', 3, 3, 1, 'Hard', 'breakfast', SYSDATE());

INSERT INTO recipes (recipeID, recipeName, instructions, author, descriptionText, prepTime, cookTime, yield, difficulty, meal, uploadDate)
VALUES (42, 'Pizza', 'Preheat oven. Place frozen pizza in oven. Wait thirty minutes.', 4, 'A savory Pizza that will bring flavor to your life', 5, 30, 8, 'easy', 'dinner', SYSDATE());

INSERT INTO recipes (recipeID, recipeName, instructions, author, descriptionText, prepTime, cookTime, yield, difficulty, meal, uploadDate)
VALUES (43, 'Chicken Noodle Soup', 'Open can. Pour in microwavable bowl. Microwave based on serving size', 4, 'Great for those winter colds!', 0, 4, 1, 'easy', 'lunch', SYSDATE());

INSERT INTO recipes (recipeID, recipeName, instructions, author, descriptionText, prepTime, cookTime, yield, difficulty, meal, uploadDate)
VALUES (44, 'Ice Cream', 'Buy it from your local market. Scoop however much you want in a bowl', 4, 'Sweet and satisfying!', 2, 2, 1, 'easy', 'dinner', SYSDATE());

INSERT INTO recipes (recipeID, recipeName, instructions, author, descriptionText, prepTime, cookTime, yield, difficulty, meal, uploadDate)
VALUES (45, 'Coffee', 'Brew Coffee beans.', 4, 'Nothing like a kick in the head to wake you up.', 1, 10, 4, 'easy', 'dinner', SYSDATE());
