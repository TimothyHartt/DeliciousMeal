//Website server using Express

//TODO
    //Add 'username not found' and 'incorrect password' alerts
    //Ensure valid form inputs are kept when submitting unsuccessfully
    //Add session cabability to maintain/track logins
    //Let them log out

//Grab packages
const express = require('express');
const mysql = require('mysql');
const session = require('express-session');
const bodyParser = require('body-parser');
const security = require('./Backend-files/securityTools.js'); //Import our security tools for hashing

//Set up express app
var app = express();
app.use(express.static(__dirname + '/')); //Use relative path names
app.use(bodyParser.urlencoded({ extended: true })); //Body parser - lets us grab data from the form
app.use(bodyParser.json());

app.use(session({ //Track sessions
    secret: security.generateSalt(), //Special session identifier - our salt function creates a value that works for this
    resave: false, //Don't force a save of the session info if nothing has changed
    saveUninitialized: true //Save a user if it is their first time visiting the site
}));

//Set up database connection
var connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'deliciousmeal'
});

// ------ Display Web pages ------ //

//Home Page
app.get('/home', (req, res) => {
    res.sendFile(__dirname + '/' + 'Frontend-files/home.html');
});

//Login Page
app.get('/login', (req, res) => {
    res.sendFile(__dirname + '/' + 'Frontend-files/login.html');
});

//Registration Page
app.get('/register', (req, res) => {
    res.sendFile(__dirname + '/' + 'Frontend-files/registration.html');
});
// ------------------------------- //

// ------ Methods for login, account creation, etc. ------ //

//Process user login
app.post('/loginRequest', (req, res) => {

    //Store the submitted info
    var username = req.body.username;
    var password = req.body.password;

    //Database query - sees if the given username exists and grabs their salt/hashed password data if they do
    var query = `SELECT salt, hashedPassword FROM users WHERE username = '${username}'`;

    //Query the database if both fields submitted
    if (username && password) {
        connection.query(query, (error, results, fields) => {
            //If username found
            if (results.length > 0) {
                //Put query results into a usable form
                var userSalt = results[0].salt;
                var userPW = results[0].hashedPassword;

                //Hash the given password with the user's salt
                var hash = security.SHA256(password + userSalt);

                //Compare computed hash to user's stored password hash
                if (hash == userPW) {
                    //If the passwords match, login and redirect to home page
                    req.session.loggedin = true;
                    req.session.username = username;
                    res.redirect('/home');
                    console.log(`- User '${username}' logged in successfully`);
                }
                else {
                    //If not, go back to the login page to try again
                    res.redirect('/login');
                    console.log(`- User '${username}' failed to login`);
                }
            }
            //If username not found, go back to the login page
            else {
                console.log(`- Login attempt failed for username '${username}'`);
                res.redirect('/login');
            }
        });
    }
    //If at least one field left blank, have them try again
    else {
        res.redirect('/login');
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
        connection.query(checkQuery, (error, results, fields) => {
            //If username found, go back to register page
            if (results.length > 0) {
                res.redirect('/register');
            }
            //If username is new and unique
            else {
                if (password == confirmPassword) {
                    //Hash and salt the user's password
                    var salt = security.generateSalt();
                    var hash = security.SHA256(password + salt);

                    //Add the new user to the database
                    var insertQuery = `INSERT INTO users (username, firstName, lastName, email, salt, hashedPassword)
                                       VALUES ('${username}', '${firstName}', '${lastName}', '${email}', '${salt}', '${hash}')`;
                    connection.query(insertQuery, (error, result) => {
                        if (error) throw error;
                        console.log(`- New user with username '${username}' successfully added to database`);
                        
                        //Log them in and redirect to homepage
                        req.session.loggedin = true;
                        req.session.username = username;
                        console.log(`- User ${username} logged in following registration`);
                        res.redirect('/home');
                    });
                }
                //Go back if passwords don't match
                else {
                    res.redirect('/register');
                }
            }
        });
    }
});
// ------------------------------------------ //

// Leave the NodeJS web server listening on port 5000
var server = app.listen(5000, () => {
    var port = server.address().port;
    console.log('Server listening on port', port);
});
