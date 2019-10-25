// Server which hosts the website

//Grab packages to use, establish port
const http = require('http');
const fs = require('fs');
const url = require('url');
const port = 5000;

//Create server
const server = http.createServer((req, res) => {
    var q = url.parse(req.url, true);
    var filename = "." + q.pathname;

    fs.readFile(filename, (err, data) => {
        //Give 404 if failure
        if (err) {
            res.writeHead(404, {'Content-Type': 'text/html'});
            return res.end("404 Not Found");
        }
        //If successful, print html to webpage
        res.writeHead(200, {'Content-Type': 'text/html'});
        res.write(data);
        return res.end();
    });
});
//Listen for new requests
server.listen(port);
console.log("Server running on port " + port);
