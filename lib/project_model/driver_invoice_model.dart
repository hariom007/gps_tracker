import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

List<DriverInvoice> getDriverInvoiceListFromJson(String str) =>
    List<DriverInvoice>.from(json.decode(str).map((x) => DriverInvoice.fromJson(x)));

String getDriverInvoiceListToJson(List<DriverInvoice> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DriverInvoice{
  String id;
  String UserName;
  String UserMobile;
  String UserEmail;
  String UserAddress;
  String Invoice;

  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  DriverInvoice({
    this.id,
    this.UserName,
    this.UserMobile,
    this.UserEmail,
    this.UserAddress,
    this.Invoice
  });
  factory DriverInvoice.fromJson(Map<String, dynamic> json) => DriverInvoice(
    id: json['id'],
    UserName: json['UserName'],
    UserMobile: json['UserMobile'],
    UserEmail: json['UserEmail'],
    UserAddress: json['UserAddress'],
    Invoice: json['Invoice']
  );

  Map<String,dynamic> toJson() => {
    'id' : id,
    'UserName' : UserName,
    'UserMobile' : UserMobile,
    'UserEmail' : UserEmail,
    'UserAddress' : UserAddress,
    'Invoice' : Invoice
  };
}