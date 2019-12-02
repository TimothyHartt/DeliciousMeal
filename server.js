//Website server using Express

//Grab packages
const express = require('express');
const mysql = require('mysql');
const session = require('express-session');
const MySQLStore = require('express-mysql-session')(session); //Lets us store sessions in our database
const bodyParser = require('body-parser'); //Lets us grab form inputs
const security = require('./Backend-files/securityTools.js'); //Import our security tools
const funcs = require('./Backend-files/serverFunctions.js'); //Import our external server functions

//Set up express app
var app = express();
app.use(express.static(__dirname + '/')); //Use relative path names
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.set('view engine', 'pug'); //Use PUG for dynamic HTML

//Set up database connection and MySQL Store
var dbOptions = {
    host: 'localhost',
    user: 'root',
    password: 'password123',
    database: 'deliciousmeal',
    clearExpired: true, //Remove expired sessions from the database
    checkExpirationInterval: 86400000, //Check for and delete expired sessions every 24 hours
    expiration: 86400000 //Sessions expire after 24 hours
};

var connection = mysql.createConnection(dbOptions);
var sessionStore = new MySQLStore(dbOptions, connection);
var onlineUsers = []; //Track which users are currently logged in

connection.connect(function(err) {
    if (err) {
        console.error('Error:- ' + err.stack);
        return;
    }

    console.log('Connected Id:- ' + connection.threadId);
});

//Set up session tracking
app.use(session({
    secret: security.generateSalt(), //Special session identifier - our salt function creates a value that works for this
    store: sessionStore, //Store the sessions in our database
    resave: false, //Don't save session info if nothing has changed
    saveUninitialized: true //Save a user if it's their first time visiting the site
}));

// ------ Display Web pages ------ //

//Home Page
app.get('/home', (req, res) => {
    res.render('homeExample', {
        un: req.session.username,
        li: req.session.loggedin
    });
});

//Login Page
app.get('/login', (req, res) => {
    res.render('loginExample');
});

//Registration Page
app.get('/register', (req, res) => {
    res.render('registrationExample');
});

//User Profile Page
app.get('/user/:name', (req, res) => {

    //Make sure the user is logged in and trying to access their own profile
    if (req.params.name === req.session.username) {
        res.render('userExample', {
            un: req.session.username
        });
    }
    else {
        res.send("You must be logged in as that user to view their profile");
    }
});

//User Initial Setup Page
// This is called automatically right after registration but can be called again any time
app.get('/user/:name/initialsetup', (req, res) => {

    //Make sure the user is logged in and trying to access their own page
    if (req.params.name === req.session.username) {
        res.render('initialsetup', {
            un: req.session.username
        });
    }
    else {
        res.send("You must be logged in as that user");
    }
});

//User saved recipes
app.get('/user/:name/favorites', (req, res) => {

    //Make sure the user is logged in and trying to access their own page
    if (req.params.name === req.session.username) {

        //Get the user's id based on their username
        var query = 'SELECT userID FROM users WHERE username = ?';
        connection.query(query, [req.session.username], (err, results) => {
            if (err) throw err;
            var id = results[0].userID;

            //Get all recipes that are favorited by the user
            var recipeQuery = 'SELECT recipe FROM savedRecipes WHERE userIndex = ? ORDER BY recipe ASC';
            connection.query(recipeQuery, [id], (err, results) => {
                if (err) throw err;

                //Add all favorite recipe ids to a list
                var savedRecipes = [];
                for (var i = 0; i < results.length; i++) {
                    savedRecipes.push(results[i].recipe);
                }

                //If the user has recipes saved
                if (savedRecipes.length > 0) {
                    //Grab the names of each favorite recipe
                    var recipeNameQuery = 'SELECT recipeName FROM recipes WHERE recipeID IN (?) ORDER BY recipeID ASC';
                    connection.query(recipeNameQuery, [savedRecipes], (err, results) => {
                        if (err) throw err;

                        //Add all recipe names to a list
                        var recipeNames = [];
                        for (var i = 0; i < results.length; i++) {
                            recipeNames.push(results[i].recipeName);
                        }

                        //Load the page, passing in the ids and names of each favorite recipe
                        res.render('favoritesExample', {
                            un: req.session.username,
                            recipes: savedRecipes,
                            names: recipeNames
                        });
                    });
                }
                //If the user has no recipes saved
                else {
                    res.render('favoritesExample', {
                        un: req.session.username,
                        recipes: savedRecipes
                    });
                }
            });
        });
    }
    else {
        res.send("You must be logged in as that user");
    }
});

//Recipes created by the user
app.get('/user/:name/myrecipes', (req, res) => {

    //Make sure the user is logged in and trying to access their own page
    if (req.params.name === req.session.username) {

        //Get the user's id based on their username
        var query = 'SELECT userID FROM users WHERE username = ?';
        connection.query(query, [req.session.username], (err, results) => {
            if (err) throw err;
            var id = results[0].userID;

            //Get all recipes created by the user
            var recipeQuery = 'SELECT recipeID FROM recipes WHERE author = ? ORDER BY recipeID ASC';
            connection.query(recipeQuery, [id], (err, results) => {
                if (err) throw err;

                //Add all recipe ids to a list
                var recipeList = [];
                for (var i = 0; i < results.length; i++) {
                    recipeList.push(results[i].recipeID);
                }

                //If the user has submitted any recipes
                if (recipeList.length > 0) {
                    //Grab the names of each recipe
                    var recipeNameQuery = 'SELECT recipeName FROM recipes WHERE recipeID IN (?) ORDER BY recipeID ASC';
                    connection.query(recipeNameQuery, [recipeList], (err, results) => {
                        if (err) throw err;

                        //Add all recipe names to a list
                        var recipeNames = [];
                        for (var i = 0; i < results.length; i++) {
                            recipeNames.push(results[i].recipeName);
                        }

                        //Load the page, passing in the ids and names of each recipe
                        res.render('myrecipes', {
                            un: req.session.username,
                            recipes: recipeList,
                            names: recipeNames
                        });
                    });
                }
                //If the user has not submitted any recipes
                else {
                    res.render('myrecipes', {
                        un: req.session.username,
                        recipes: recipeList
                    });
                }
            });
        });
    }
    else {
        res.send("You must be logged in as that user");
    }
});

//User settings
app.get('/user/:name/settings', (req, res) => {

    //Make sure the user is logged in and trying to access their own page
    if (req.params.name === req.session.username) {
        res.render('settingsExample', {
            un: req.session.username
        });
    }
    else {
        res.send("You must be logged in as that user");
    }
});

//Recipe page
app.get('/recipe/:recipeid', (req, res) => {

    //Grab the recipe data based on the ID
    var recipeQuery = 'SELECT * FROM recipes WHERE recipeID = ?';
    connection.query(recipeQuery, [req.params.recipeid], (err, results) => {
        if (err) throw err;

        //If a result is found
        if (results.length > 0) {
            var recipe = results[0];
            var yield = results[0].yield; //Number of servings

            //Get the username of the recipe's author based on their ID
            var unQuery = 'SELECT username FROM users WHERE userID = ?';
            connection.query(unQuery, [recipe.author], (err, results) => {
                if (err) throw err;

                var user = results[0].username;

                //Get all the ingredients and their data
                var ingQuery = 'SELECT ingredient, quantity, measurementUnit FROM recipeIngredients WHERE recipe = ?';
                connection.query(ingQuery, [req.params.recipeid], (err, results) => {
                    if (err) throw err;

                    //Populate an array with lists containing the quantity and unit of each ingredient
                    var ingredients = [];
                    var ingredientData = [];
                    var list = [];

                    for (i = 0; i < results.length; i++) {
                        list = [];
                        list.push(results[i].quantity);
                        list.push(results[i].measurementUnit);
                        ingredients.push(results[i].ingredient);
                        ingredientData.push(list);
                    }

                    //If the recipe has ingredients, get their names
                    if (ingredients.length > 0) {
                        var ingNameQuery = 'SELECT ingredientName FROM ingredients WHERE ingredientID IN (?)';
                        connection.query(ingNameQuery, [ingredients], (err, results) => {
                            if (err) throw err;

                            //Add the names to each ingredient
                            for (i = 0; i < results.length; i++) {
                                ingredientData[i].push(results[0].ingredientName);
                            }
                            showRecipe();
                        });
                    }
                    //If there are no ingredients, show the recipe without getting ingredients
                    else {
                        showRecipe();
                    }

                    function showRecipe() {
                        //Show the page, including the ingredient data we collected
                        res.render('recipe', {
                            ingredientList: ingredientData,
                            name: recipe.recipeName,
                            instructions: recipe.instructions,
                            author: user,
                            description: recipe.descriptionText,
                            prepT: recipe.prepTime,
                            cookT: recipe.cookTime,
                            totalT: recipe.totalTime,
                            servings: yield,
                            id: req.params.recipeid
                            tools: funcs //Make the server functions accessible from the page
                            //Add any other data we need here
                        });
                    }
                });
            });
        }
        //If no recipe exists with that ID
        else {
            res.send("Recipe not found");
        }
    });
});

//Recipe reviews
app.get('/recipe/:recipeid/reviews', (req, res) => {

    //Get all the reviews for this recipe, with the most recent ones first
    var query = 'SELECT * FROM reviews WHERE recipe = ? ORDER BY submissionDate DESC';
    connection.query(query, [req.params.recipeid], (err, results) => {
        if (err) throw err;

        if (results.length > 0) {
            var reviewList = results;

            //Store the user ids for each recipe in both an array and a string
            var ids = [];
            var fields = ''; //This will indicate the order in which we want the usernames returned, based on the user id
            for (i = 0; i < reviewList.length; i++) {
                ids.push(reviewList[i].author);
                fields += reviewList[i].author + ',';
            }
            fields = fields.slice(0, -1); //Remove the last comma from the string

            //Get the author's username for each id we grabbed, and return them in the same order as the recipes they wrote
            var unQuery = `SELECT username FROM users WHERE userID IN (?) ORDER BY FIELD(userID, ${fields})`;
            connection.query(unQuery, [ids], (err, results) => {
                if (err) throw error;

                //Add the author's username to the end of the json for each review
                for (i = 0; i < results.length; i++) {
                    reviewList[i].username = results[i].username;
                }

                //Load the page and pass in the list of reviews as a JSON
                res.render('reviews', {
                    un: req.session.username,
                    reviews: reviewList
                });
            });
        }
        else {
            res.send("No reviews for this recipe yet");
        }
    });
});

//Let the user add a new recipe with ingredients
app.get('/addrecipe', (req, res) => {

    //Only let people add recipes while logged in
    if (req.session.loggedin) {

        //Get all the ingredients
        var ingredients = [];
        var inQuery = 'SELECT * FROM ingredients';
        connection.query(inQuery, (err, results) => {

            for (i = 0; i < results.length; i++) {
                ingredients.push(results[i].ingredientName);
            }

            req.session.ingredientList = ingredients; //Store ingredients in a local session variable

            res.render('addrecipe', {
                countryList: funcs.getCountries(),
                ing: ingredients,
                units: funcs.getUnits()
            });
        });
    }
    else {
        res.render('loginExample', {
            err: 'Please log in to add a new recipe'
        });
    }
});



app.get('/addIngredient', (req,res) =>{
  if(req.session.loggedin){
    res.render('addIngredient', {

    });
  }else{
    res.render('addIngredient', {
        err: 'Please log in to add a new Ingredient'
    });
  }

});



// ------------------------------- //

// ------ Methods for important events ------ //

//Process user login
app.post('/loginRequest', (req, res) => {

    //Store the submitted info
    var username = req.body.username;
    var password = req.body.password;

    //Database query - Check username exists, grab salt and hashed password if it does
    var query = 'SELECT salt, hashedPassword FROM users WHERE username = ?';

    //If user logged in elsewhere
    if (onlineUsers.includes(username)) {
        res.render('loginExample', {
            err: 'User already logged in',
            un: username
        });
        console.log(`- Redundant login attempt for '${username}'. User was already signed in.`);
        return;
    }

    //Query the database if both fields submitted
    if (username && password) {
        connection.query(query, [username], (err, results) => {
            if (err) throw err;

            //If username found
            if (results.length > 0) {
                //Put query results into a usable form
                var userSalt = results[0].salt;
                var userPW = results[0].hashedPassword;

                //Hash the given password with the user's salt
                var hash = security.SHA256(password + userSalt);

                //If the hash matches the stored password, login and redirect to home page
                if (hash == userPW) {
                    req.session.loggedin = true;
                    req.session.username = username;
                    onlineUsers.push(username); //Add username to list of logged-in users
                    res.redirect('/home');
                    console.log(`- User '${username}' logged in successfully`);
                }
                //If not, go back to the login page to try again
                else {
                    res.render('loginExample', {
                        err: 'Incorrect password',
                        un: username
                    });
                    console.log(`- User '${username}' failed to login`);
                }
            }
            //If username not found, go back to the login page
            else {
                res.render('loginExample', {
                    err: 'Username not found',
                    un: username
                });
                console.log(`- Login attempt failed for username '${username}'`);
            }
        });
    }
});

//Process account creation request
app.post('/createAccount', (req, res) => {

    //Store the submitted info
    var username = req.body.username;
    var password = req.body.password;
    var confirmPassword = req.body.confirmPassword;
    var email = req.body.email;
    var firstName = req.body.firstName;
    var lastName = req.body.lastName;

    //If all required info is submitted
    if (username && password && confirmPassword && email) {

        //Check that the username does not already exist
        var checkQuery = 'SELECT userID FROM users WHERE username = ?';
        connection.query(checkQuery, [username], (err, results) => {
            if (err) throw err;

            //If username already exists
            if (results.length > 0) {
                res.render('registrationExample', {
                    err: 'Username already in use',
                    un: username,
                    em: email,
                    fn: firstName,
                    ln: lastName
                });
            }
            else {
                //If username is new and both passwords match, hash and salt the password
                if (password == confirmPassword) {
                    var salt = security.generateSalt();
                    var hash = security.SHA256(password + salt);

                    //Add the new user to the database
                    var insertQuery = 'INSERT INTO users (username, firstName, lastName, email, salt, hashedPassword) VALUES (?, ?, ?, ?, ?, ?)';
                    connection.query(insertQuery, [username, firstName, lastName, email, salt, hash], (err) => {
                        if (err) throw err;
                        console.log(`- New user with username '${username}' successfully added to database`);

                        //Log them in and send them to initial setup
                        req.session.loggedin = true;
                        req.session.username = username;
                        onlineUsers.push(username); //Add username to list of logged-in users
                        console.log(`- User ${username} logged in following registration`);
                        res.redirect('/user/' + username + '/initialsetup');
                    });
                }
                //Go back if passwords don't match
                else {
                    res.render('registrationExample', {
                        err: 'Passwords do not match',
                        un: username,
                        em: email,
                        fn: firstName,
                        ln: lastName
                    });
                }
            }
        });
    }
});

//Log the user out by deleting their current session
app.post('/logout', (req, res) => {

    //Make sure they are logged in first
    if (req.session.username) {
        console.log(`- Logged out user '${req.session.username}'`);
        delete onlineUsers[onlineUsers.indexOf(req.session.username)];
        req.session.destroy();
    }
    res.redirect('/home');
});

//Search algorithm
app.post('/search', (req, res) => {
    //INSERT SEARCH ALGORITHM HERE

    var searchAlgorithm = '';
});

app.post('/submitIngredient', (req,res ) =>{
  var ingredientName = req.body.ingredientName;
  var foodType = req.body.foodType;
  var sweetIndex = req.body.sweetIndex;
  var saltyIndex = req.body.saltyIndex;
  var sourIndex = req.body.sourIndex;
  var bitterIndex = req.body.bitterIndex;
  var umamiIndex = req.body.umamiIndex;
  var spiciness = req.body.Spicy;



  var insertQuery = 'INSERT INTO Ingredients( ingredientName, foodType, sweetScore, saltyScore, sourScore, bitterScore,umamiScore,spiciness) VALUES (?,?,?,?,?,?,?,?)';
  connection.query(insertQuery, [ingredientName,foodType,sweetIndex,saltyIndex,sourIndex,bitterIndex,umamiIndex,spiciness], (err) => {
    if(err) throw err;

  });
});

//Add a recipe (Incomplete - currently only allows one ingredient)
app.post('/submitRecipe', (req, res) => {

    var recipeName = req.body.recipeName;
    var instructions = req.body.instructions;
    var description = req.body.description;
    var prepTime = req.body.prepTime;
    var cookTime = req.body.cookTime;
    var servings = req.body.servings;
    var difficulty = req.body.difficulty;
    var meal = req.body.meal;
    var country = req.body.country;

    var ingredient = req.body.ingredient;
    var quantity = req.body.quantity;
    var unit = req.body.unit;

    var totalTime = parseInt(prepTime) + parseInt(cookTime);

    //Convert the quantity to a decimal
    var intPattern = /^\d{1,3}$/;
    var floatPattern = /^\d{1,3}\.\d{1,3}$/;
    var fractionPattern = /^[1-9]\/[1-9]$/;

    //If they gave a valid fraction, make it a decimal
    if (fractionPattern.test(quantity)) {
        quantity = funcs.fractionToDecimal(quantity);
    }
    //If they gave a valid integer or decimal, make it a decimal
    else if (floatPattern.test(quantity) || intPattern.test(quantity)) {
        quantity = parseFloat(quantity);
    }
    //Try again if they gave invalid input
    else {
        quantity = 0;
        res.render('addrecipe', {
            err: 'Please enter a valid quantity. Fractions should be in the form "x/y".',
            countryList: funcs.getCountries(),
            ing: req.session.ingredientList,
            units: funcs.getUnits(),
            rname: recipeName,
            inst: instructions,
            desc: description,
            prep: prepTime,
            cook: cookTime,
            srv: servings
        });
        return;
    }

    //Get the user's ID based on their username
    var idQuery = 'SELECT userID FROM users WHERE username = ?';
    connection.query(idQuery, [req.session.username], (err, results) => {
        if (err) throw err;
        var author = results[0].userID;

        //Add null if they didn't choose a difficulty, meal, or country
        if (difficulty == '')
            difficulty = null;
        if (meal == '')
            meal = null;
        if (country == '')
            country = null;

        //Add the recipe
        var insertQuery = 'INSERT INTO recipes(recipeName, instructions, author, countryOfOrigin, descriptionText, prepTime, cookTime, totalTime, yield, difficulty, meal, uploadDate) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, SYSDATE())';
        connection.query(insertQuery, [recipeName, instructions, author, country, description, prepTime, cookTime, totalTime, servings, difficulty, meal], (err) => {
            if (err) throw err;

            //Get the id of the recipe we just added
            var recipeQuery = 'SELECT recipeID FROM recipes ORDER BY uploadDate DESC LIMIT 1'; //Grab the newest recipe
            connection.query(recipeQuery, [author], (err, results) => {
                if (err) throw err;
                var recipeid = results[0].recipeID;

                //If they included ingredients
                if (ingredient != '') {
                    //Get the id for the ingredient we added
                    var ingredientQuery = 'SELECT ingredientID FROM ingredients WHERE ingredientName = ?';
                    connection.query(ingredientQuery, [ingredient], (err, results) => {
                        if (err) throw err;
                        var ingredientID = results[0].ingredientID;

                        //Add a new recipe ingredient
                        var ingredientInsertQuery = 'INSERT INTO recipeIngredients(recipe, ingredient, quantity, measurementUnit) VALUES(?, ?, ?, ?)';
                        connection.query(ingredientInsertQuery, [recipeid, ingredientID, quantity, unit], (err) => {
                            if (err) throw err;

                            //Go to the new recipe page
                            res.redirect('recipe/' + recipeid);
                        });
                    });
                }
                //If they didn't include ingredients
                else {
                    res.redirect('recipe/' + recipeid);
                }
            });
        });
    });
});
// ------------------------------------------------------- //

//Handle 404 errors
app.use((req, res) => {
    res.status(404).send('Error 404 - Page Not Found');
});

//Handle 500 errors
app.use((err, req, res, next) => {
    console.error(err.stack); //Log error details
    res.status(500).send('Error 500 - Internal Server Error');
});

//Leave the NodeJS web server listening on port 5000
var server = app.listen(5000, () => {
    var port = server.address().port;
    console.log('Server listening on port', port);
});
