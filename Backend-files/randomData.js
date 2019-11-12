const mysql = require('mysql');

//Set up database connection and MySQL Store
var dbOptions = {
    host: 'localhost',
    user: 'root',
    password: 'password123',
    database: 'deliciousmeal'
};

var connection = mysql.createConnection(dbOptions);

connection.connect(function(err){

  if(err) throw err;
  console.log("Random Data Insertion Connected.");

  var sql = "INSERT INTO ingredients (ingredientName, foodType, sweetScore, saltyScore, sourScore, bitterScore, umamiScore, spiciness) VAlUES ?";

  var values = [];

  for(var i = 0;i<6; i ++){
    values.push(["Food_"+i,"SomeType"+Math.floor(Math.random() * 10),  Math.floor(Math.random() * 10), Math.floor(Math.random() * 10), Math.floor(Math.random() * 10), Math.floor(Math.random() * 10), Math.floor(Math.random() * 10),Math.floor(Math.random() * 10)]);
  }

  connection.query(sql,[values],function(err, result){
    if(err) throw err;
    console.log("Number of rows added: " + result.affectedRows);
  })

});
