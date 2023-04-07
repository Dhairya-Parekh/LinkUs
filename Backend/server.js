const express = require("express");
const query = require('./query');


const app = express();

// set port, listen for requests
const PORT = process.env.BACKEND_PORT || 8080;


app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}.`);
});

// app.use((req, res, next) => {
//   res.header("Access-Control-Allow-Origin", "http://localhost:3000");
//   res.header("Access-Control-Allow-Credentials", "true");
//   res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
//   next();
// });

// parsing the incoming data
// app.use(express.json());
// app.use(express.urlencoded({ extended: true }));
//-------------------------------------------------------------------------------------------------------------------------------------------------------
query.get_group_members({group_id: 123})
app.post('/login', (req, res) => {
  query.login(req.body)
    .then(response => {
      res.status(200).send(response);
    })
    .catch(error => {
      res.status(500).send(error);
    })
})

//-------------------------------------------------------------------------------------------------------------------------------------------------------

app.post('/signup', (req, res) => {
  query.signup(req.body)
    .then(response => {
      res.status(200).send(response);
    })
    .catch(error => {
      res.status(500).send(error);
    })
})

//-------------------------------------------------------------------------------------------------------------------------------------------------------

app.post('/create_group', (req, res) => {
  query.new_group(req.body)
    .then(response => {
      for(let i = 0; i < req.body.members.length; i++){
        if(req.body.members[i] != req.body.user_id){
          temp_body = {user_id : req.body.members[i], group_id : response.group_id}
          query.add_all_to_participants(temp_body);
        }
      }
      res.status(200).send(response);
    })
    .catch(error => {
      res.status(500).send(error);
    })
})

//-------------------------------------------------------------------------------------------------------------------------------------------------------



//-------------------------------------------------------------------------------------------------------------------------------------------------------

app.post('/send_message', (req, res) => {
  query.new_message(req.body)
    .then(response => {
      temp_body = {group_id: req.body.group_id}
      query.get_group_members(temp_body)
      .then(response1 => {
        for(let i = 0; i < response1.length; i++){
          if(response1[i].user_id != req.body.user_id){
            temp_body = {receiver_id : response1[i].user_id, sender_id : req.body.user_id, link_id : response.link_id}
            query.add_send_message_to_message_action(temp_body);
          }
        }
        res.status(200).send(response);
      })
    })
    .catch(error => {
      res.status(500).send(error);
    })
})

//-------------------------------------------------------------------------------------------------------------------------------------------------------



//-------------------------------------------------------------------------------------------------------------------------------------------------------



//-------------------------------------------------------------------------------------------------------------------------------------------------------



//-------------------------------------------------------------------------------------------------------------------------------------------------------



//-------------------------------------------------------------------------------------------------------------------------------------------------------



//-------------------------------------------------------------------------------------------------------------------------------------------------------



//-------------------------------------------------------------------------------------------------------------------------------------------------------

app.post('/delete_message', (req, res) => {
  temp_body = {link_id: req.body.link_id}
  query.remove_link(temp_body)
    .then(response => {
      temp_body = {group_id: req.body.group_id}
      query.get_group_members(temp_body)
      .then(response1 => {
        for(let i = 0; i < response1.length; i++){
          if(response1[i].user_id != req.body.user_id){
            temp_body = {receiver_id : response1[i].user_id, group_id: req.body.group_id, affected_id: req.body.new_member_id, affected_role: req.body.role, time_stamp: response.time_stamp}
            query.add_new_member_to_group_action(temp_body);
          }
        }
        res.status(200).send(response);
      })
    })
    .catch(error => {
      res.status(500).send(error);
    })
})

//-------------------------------------------------------------------------------------------------------------------------------------------------------

app.post('/add_user', (req, res) => {
  temp_body = {user_id: req.body.new_member_id, group_id: req.body.group_id}
  query.add_one_to_participants(temp_body)
    .then(response => {
      temp_body = {group_id: req.body.group_id}
      query.get_group_members(temp_body)
      .then(response1 => {
        for(let i = 0; i < response1.length; i++){
          if(response1[i].user_id != req.body.user_id){
            temp_body = {receiver_id : response1[i].user_id, group_id: req.body.group_id, affected_id: req.body.new_member_id, affected_role: req.body.role, time_stamp: response.time_stamp}
            query.add_new_member_to_group_action(temp_body);
          }
        }
        res.status(200).send(response);
      })
    })
    .catch(error => {
      res.status(500).send(error);
    })
})

//-------------------------------------------------------------------------------------------------------------------------------------------------------

app.post('/change_role', (req, res) => {
  query.change_role(req.body)
    .then(response => {
      temp_body = {group_id: req.body.group_id}
      query.get_group_members(temp_body)
      .then(response1 => {
        for(let i = 0; i < response1.length; i++){
          if(response1[i].user_id != req.body.user_id){
            temp_body = {receiver_id : response1[i].user_id, group_id: req.body.group_id, affected_id: req.body.user_id, affected_role: req.body.role, time_stamp: response.time_stamp}
            query.add_change_role_to_group_action(temp_body);
          }
        }
        res.status(200).send(response);
      })
    })
    .catch(error => {
      res.status(500).send(error);
    })
})

//-------------------------------------------------------------------------------------------------------------------------------------------------------

app.post('/remove_member', (req, res) => {
  query.remove_from_participants(req.body)
    .then(response => {
      temp_body = {group_id: req.body.group_id}
      query.get_group_members(temp_body)
      .then(response1 => {
        for(let i = 0; i < response1.length; i++){
          if(response1[i].user_id != req.body.user_id){
            temp_body = {receiver_id : response1[i].user_id, group_id: req.body.group_id, affected_id: req.body.user_id, time_stamp: response.time_stamp}
            query.add_remove_user_to_group_action(temp_body);
          }
        }
        res.status(200).send(response);
      })
    })
    .catch(error => {
      res.status(500).send(error);
    })
})

//-------------------------------------------------------------------------------------------------------------------------------------------------------

