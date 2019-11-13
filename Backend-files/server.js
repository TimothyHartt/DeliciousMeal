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
    password: '',
    database: 'deliciousmeal',
    clearExpired: true, //Remove expired sessions from the database
    checkExpirationInterval: 86400000, //Check for and delete expired sessions every 24 hours
    expiration: 86400000 //Sessions expire after 24 hours
};

var connection = mysql.createConnection(dbOptions);
var sessionStore = new MySQLStore(dbOptions, connection);
var onlineUsers = []; //Track which users are currently logged in

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
    res.render('home', {
        un: req.session.username,
        li: req.session.loggedin
    });
});

//Login Page
app.get('/login', (req, res) => {
    res.render('login');
});

//Registration Page
app.get('/register', (req, res) => {
    res.render('registration');
});
// ------------------------------- //

// ------ Methods for login, account creation, etc. ------ //

//Process user login
app.post('/loginRequest', (req, res) => {

    //Store the submitted info
    var username = req.body.username;
    var password = req.body.password;

    //Database query - Check username exists, grab salt and hashed password if it does
    var query = `SELECT salt, hashedPassword FROM users WHERE username = '${username}'`;

    //If user logged in elsewhere
    if (onlineUsers.includes(username)) {
        res.render('login', {
            err: 'User already logged in',
            un: username
        });
        console.log(`- Redundant login attempt for '${username}'. User was already signed in.`);
        return;
    }

    //Query the database if both fields submitted
    if (username && password) {
        connection.query(query, (err, results) => {
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
                    res.render('login', {
                        err: 'Incorrect password',
                        un: username
                    });
                    console.log(`- User '${username}' failed to login`);
                }
            }
            //If username not found, go back to the login page
            else {
                res.render('login', {
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
        var checkQuery = `SELECT userID FROM users WHERE username = '${username}'`;
        connection.query(checkQuery, (err, results) => {
            if (err) throw err;
            
            //If username already exists
            if (results.length > 0) {
                res.render('registration', {
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
                    var insertQuery = `INSERT INTO users (username, firstName, lastName, email, salt, hashedPassword)
                                       VALUES ('${username}', '${firstName}', '${lastName}', '${email}', '${salt}', '${hash}')`;
                    connection.query(insertQuery, (err) => {
                        if (err) throw err;
                        console.log(`- New user with username '${username}' successfully added to database`);
                        
                        //Log them in and redirect to homepage
                        req.session.loggedin = true;
                        req.session.username = username;
                        onlineUsers.push(username); //Add username to list of logged-in users
                        console.log(`- User ${username} logged in following registration`);
                        res.redirect('/home');
                    });
                }
                //Go back if passwords don't match
                else {
                    res.render('registration', {
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
});
// ------------------------------------------------------- //

//Handle 404 errors
app.use((req, res) => {
    res.status(404).send('Error 404 - Page Not Found');
});

//Handle 500 errors
app.use((error, req, res, next) => {
    res.status(500).send('Error 500 - Internal Server Error');
});

// Leave the NodeJS web server listening on port 5000
var server = app.listen(5000, () => {
    var port = server.address().port;
    console.log('Server listening on port', port);
});
