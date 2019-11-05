//Functions to be used in the server

//To add a function, use the following template:
// const 'function name' = (parameter1, paramater2, etc.) => { do something; }
//
//Then add the name of the function to the module.exports object, seperated by commas
//From there you can call it in the server function using "funcs.'function name'()"

const test = () => { //Testing
    return ('File import successful');
}

//Export functions so they ca nbe used elsewhere
module.exports = {
    test
};