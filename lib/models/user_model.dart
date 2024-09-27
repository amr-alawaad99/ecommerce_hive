class UserModel{
  String? uId;
  String? name;
  String? phone;
  String? email;


  UserModel({
    this.uId,
    this.name,
    this.phone,
    this.email,
  });

  UserModel.fromJson(Map<String,dynamic> json){
    uId = json['uId'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
  }

  Map<String, dynamic> toMap(){
    return{
      'uId' : uId,
      'name' : name,
      'phone' : phone,
      'email' : email,
    };
  }
}