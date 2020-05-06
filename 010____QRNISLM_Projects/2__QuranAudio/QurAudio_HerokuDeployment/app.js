  //jshint esversion:6


  const express = require("express");
  const path = require('path');
  const request = require("request");
  const app = express();
  const PORT = process.env.PORT || 5000;
  //app.listen(3000);


  app.use(express.static("public"));

  app.get("/",function (req,res){
    //console.log(req);
    res.sendFile(__dirname + "/index.html");
    //res.send("hello");
  });






//app.get('/cool', (req, res) => res.send(cool()));
  app.listen(PORT);
  console.log("server started on port 5000");

  /*
  const express = require('express')
  const path = require('path')
  const PORT = process.env.PORT || 5000

  express()
    .use(express.static(path.join(__dirname, 'public')))
    .set('views', path.join(__dirname, 'views'))
    .set('view engine', 'ejs')
    .get('/', (req, res) => res.render('pages/index'))
    .listen(PORT, () => console.log(`Listening on ${ PORT }`))
  */
