CREATE DATABASE IF NOT EXISTS deliciousMeal;

CREATE TABLE IF NOT EXISTS preferenceProfiles(
    preferenceProfileID INT PRIMARY KEY,
    userIndex INT,
    sweetPref TINYINT(1),
    saltyPref TINYINT(1),
    sourPref TINYINT(1),
    bitterPref TINYINT(1),
    umamiPref TINYINT(1),
    heatPref INT
);

CREATE TABLE IF NOT EXISTS users(
    userID INT PRIMARY KEY,
    username VARCHAR(32),
    firstName VARCHAR(32),
    lastName VARCHAR(32),
    email VARCHAR(32),
    salt VARCHAR(16),
    hashedPassword VARCHAR(64),
    numSavedRecipes INT,
    preferenceProfile INT
);

CREATE TABLE IF NOT EXISTS ingredientNutritionIndexes(
    ingredientNutritionID INT PRIMARY KEY,
    ingredient INT,
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
    ingredientID INT PRIMARY KEY,
    ingredientName VARCHAR(45),
    foodType VARCHAR(45),
    ingredientNutritionIndex INT,
    sweetScore TINYINT(1),
    saltyScore TINYINT(1),
    sourScore TINYINT(1),
    bitterScore TINYINT(1),
    umamiScore TINYINT(1),
    spiciness TINYINT(1)
);

CREATE TABLE IF NOT EXISTS allergens(
    userIndex INT,
    ingredient INT,
    PRIMARY KEY (userIndex, ingredient)
);

CREATE TABLE IF NOT EXISTS recipeFlavorBreakdowns(
    flavorBreakdownID INT PRIMARY KEY,
    recipe INT,
    sweetScore TINYINT(1),
    saltyScore TINYINT(1),
    sourScore TINYINT(1),
    bitterScore TINYINT(1),
    umamiScore TINYINT(1),
    heatScore TINYINT(1)
);

CREATE TABLE IF NOT EXISTS  recipeNutritionIndexes(
    recipeNutritionID INT PRIMARY KEY,
    recipe INT,
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
    recipeID INT PRIMARY KEY,
    recipeName VARCHAR(64),
    instructions VARCHAR(2048),
    rating DECIMAL(1),
    author INT,
    numRatings INT,
    numLikes INT,
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
    savedRecipeID INT PRIMARY KEY,
    userIndex INT,
    recipe INT
);

CREATE TABLE IF NOT EXISTS recipeIngredients(
    recipeIngredientID INT PRIMARY KEY,
    recipe INT,
    ingredient INT,
    quantity smallINT(4),
    measurementUnit VARCHAR(32)
);

CREATE TABLE IF NOT EXISTS tips(
    tipID INT PRIMARY KEY,
    recipe INT,
    author INT,
    tipText VARCHAR(512),
    numLikes INT
);

CREATE TABLE IF NOT EXISTS reviews(
    reviewID INT PRIMARY KEY,
    recipe INT,
    author INT,
    rating DECIMAL(1),
    submissionDate DATETIME,
    reviewText VARCHAR(2048),
    numLikes INT
);

CREATE TABLE IF NOT EXISTS pantryItems(
    pantryItemID INT PRIMARY KEY,
    ownerIndex INT,
    ingredient INT,
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