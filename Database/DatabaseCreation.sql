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
    rating DECIMAL(1),
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
    quantity smallINT(4),
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
    rating DECIMAL(1),
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
VALUES ('alicea', 'Alice', 'A', 'alicea@email.com', 'XHh7VL6vxqTOMJCX', 'F77C83A9B2C71C0608D07716738D76822E5E44F7883B145AF12C4364127C7C6E');

INSERT INTO users (username, firstName, lastName, email, salt, hashedPassword)
VALUES ('bobb', 'Bob', 'B', 'bobb@email.com', 'dZkUKLeOavB3s8Cp', 'E657873F94C46CFF7D0563765F84D6083B7D56A5BECAFF4157B12A8AE601A42E');

INSERT INTO users (username, firstName, lastName, email, salt, hashedPassword)
VALUES ('charliec', 'Charlie', 'C', 'charliec@email.com', 'LuwBUkuFe7M24OK2', '3131757FE4961B7DC974E489D690385065AA9335B464B60C7C0CDC134478A46C');

INSERT INTO users (username, firstName, lastName, email, salt, hashedPassword)
VALUES ('davidd', 'David', 'D', 'davidd@email.com', 'cR4rVr7bzrV3bYkG', '48E0C06EAAAA4052DFAD1E67EE3DDE9CF3F9AF47B3EBEA80EA48CB7B181CB0C5');

INSERT INTO users (username, firstName, lastName, email, salt, hashedPassword)
VALUES ('edwarde', 'Edward', 'E', 'edwarde@email.com', 'O8AMlyp8qGPBetrH', '53C5E3DCD43B3064FEC1025B6FE03C4A9D31664C171A7D0859D873019797EF18');