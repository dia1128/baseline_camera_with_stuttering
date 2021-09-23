/*
  Created By: Nathan Millwater
  Description: Represents a user object
 */


/// Simple class representing a user object
class User {

  String id;
  String username;
  String email;

  User({String username, String email, String id}) {
    this.id = id;
    this.username = username;
    this.email = email;
  }
  
}