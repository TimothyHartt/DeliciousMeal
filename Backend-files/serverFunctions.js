//Functions for use in the server

//To add a function, use the following template:
// const 'function name' = (parameter1, paramater2, etc.) => { do something; }
//
//Then add the name of the function to the module.exports object, seperated by commas
//From there you can call it in the server function using "funcs.'function name'()"

//Returns a list of countries
const getCountries = () => {
    var countries = ['Afghanistan', 'Albania', 'Algeria', 'American Samoa', 'Andorra', 'Angola', 'Anguilla', 'Argentina', 'Armenia', 'Aruba', 'Australia', 'Austria', 'Azerbaijan', 'Bahamas', 'Bahrain', 'Bangladesh', 'Barbados', 'Belarus', 'Belgium', 'Belize', 'Benin', 'Bermuda', 'Bhutan', 'Bolivia', 'Bosnia & Herzegovina', 'Botswana', 'Brazil', 'Brunei', 'Bulgaria', 'Burkina Faso', 'Burundi', 'Cambodia', 'Cameroon', 'Canada', 'Canary Islands', 'Cape Verde', 'Cayman Islands', 'Central African Republic', 'Chad', 'Chile', 'China', 'Colombia', 'Comoros', 'Costa Rica', 'Cote d\'Ivoire', 'Croatia', 'Cuba', 'Curacao', 'Cyprus', 'Czechia', 'Denmark', 'Djibouti', 'Dominica', 'Dominican Republic', 'Ecuador', 'Egypt', 'El Salvador', 'Eritrea', 'Estonia', 'Eswatini', 'Ethiopia', 'Falkland Islands', 'Fiji', 'Finland', 'France', 'Gabon', 'Gambia', 'Georgia', 'Germany', 'Ghana', 'Gibraltar', 'Greece', 'Greenland', 'Grenada', 'Guadeloupe', 'Guam', 'Guatemala', 'Guernsey', 'Guinea', 'Guyana', 'Haiti', 'Honduras', 'Hong Kong', 'Hungary', 'Iceland', 'India', 'Indonesia', 'Iran', 'Iraq', 'Ireland', 'Israel', 'Italy', 'Jamaica', 'Japan', 'Jersey', 'Jordan', 'Kazakhstan', 'Kenya', 'Kiribati', 'Kosovo', 'Kuwait', 'Kyrgyzstan', 'Laos', 'Latvia', 'Lebanon', 'Lesotho', 'Liberia', 'Libya', 'Liechtenstein', 'Lithuania', 'Luxembourg', 'Madagascar', 'Malawi', 'Malaysia', 'Maldives', 'Mali', 'Malta', 'Martinique', 'Mauritania', 'Mauritius', 'Mayotte', 'Mexico', 'Micronesia', 'Moldova', 'Monaco', 'Mongolia', 'Montenegro', 'Montserrat', 'Morocco', 'Mozambique', 'Myanmar (Burma)', 'Namibia', 'Nauru', 'Nepal', 'Netherlands', 'New Zealand', 'Nicaragua', 'Niger', 'Nigeria', 'Niue', 'North Korea', 'North Macedonia', 'Norway', 'Oman', 'Pakistan', 'Palau', 'Palestinian Territories', 'Panama', 'Papua New Guinea', 'Paraguay', 'Peru', 'Philippines', 'Poland', 'Portugal', 'Puerto Rico', 'Qatar', 'Reunion', 'Romania', 'Russia', 'Rwanda', 'Samoa', 'San Marino', 'Saudi Arabia', 'Senegal', 'Serbia', 'Seychelles', 'Sierra Leone', 'Singapore', 'Slovakia', 'Slovenia', 'Somalia', 'South Africa', 'South Korea', 'South Sudan', 'Spain', 'Sri Lanka', 'Sudan', 'Suriname', 'Sweden', 'Switzerland', 'Syria Taiwan', 'Tajikistan', 'Tanzania', 'Thailand', 'Timor', 'Togo', 'Tokelau', 'Tonga', 'Trinidad & Tobago', 'Tunisia', 'Turkey', 'Turkmenistan', 'Uganda', 'Ukraine', 'United Arab Emirates', 'United Kingdom', 'United States', 'Uruguay', 'Uzbekistan', 'Vanuatu', 'Venezuela', 'Vietnam', 'Yemen', 'Zambia', 'Zimbabwe'];
    return countries;
}

//Returns a list of measurement units
const getUnits = () => {
    var units = ['cup', 'ounce', 'gram', 'milliliter', 'teaspoon', 'tablespoon', 'pint', 'quart', 'pinch', 'drop'];
    return units;
}

//Converts a fraction to a decimal
const fractionToDecimal = (fraction) => {
    var split = fraction.split('/');
    var decimal = split[0] / split[1];
    return parseFloat(decimal.toFixed(3)); //Round to 3 decimal places
}

//Convert a decimal to a fraction - based on https://gist.github.com/redteam-snippets/3934258
const decimalToFraction = (decimal) => {
    var top = decimal.replace(/\d*[.]/, ''); //Save just the part after the decimal
    var bottom = Math.pow(10, top.length);

    if (decimal >= 1)
        top = Number(top) + Math.floor(decimal) * bottom;

    //Simplify the fraction with the greatest common divisor
    var x = gcd(top, bottom);
    top /= x;
    bottom /= x;

    //If the denominator is 1, remove it. Otherwise return the whole fraction
    return (bottom == 1) ? top : (top + '/' + bottom);
}

//Greatest Common Divisor
const gcd = (a, b) => {
    return b ? gcd(b, a % b) : a;
}

//search algorithm
 
const searchFunctionBasic = function (searchString, numResults = 15) {
	query = "SELECT recipeName, rating, totalTime, recipeID FROM recipes Order By DIFFERENCE(" + searchString + ", recipeName);";
}

//Export functions so they can be used elsewhere
module.exports = {
    getCountries,
    getUnits,
    fractionToDecimal,
    decimalToFraction,
    gcd,
    searchFunctionBasic
};


