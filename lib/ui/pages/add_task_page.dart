import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_management/controllers/task_controller.dart';
import 'package:task_management/models/task.dart';
import 'package:task_management/ui/theme.dart';
import 'package:task_management/ui/widgets/button.dart';
import 'package:task_management/ui/widgets/input_field.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
//Gerekli kütüphaneleri ekliyoruz.

//AddTaskPage adında bir durum sınıfı oluşturuyoruz
class AddTaskPage extends StatefulWidget {
  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  //Veri tabanında yapacağımız eklemeler için başlık, not açıklaması ve görev ayarlamaları
  final TaskController _taskController = Get.find<TaskController>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  //Dosyadan zil sesi seçmek için FilePicker kütüphanesi değişken ayarlamaları
  FilePickerResult? result;
  String? _fileName;
  PlatformFile? pickedFile;
  bool isLoading = false;
  File? fileToDisplay;

  //Zil sesi dosyasını seçmek için yazdığımız pickFile fonksiyonu
  void pickFile() async {
    try {
      setState(() {
        isLoading = true;
      });
      result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null) {
        _fileName = result!.files.first.name;
        pickedFile = result!.files.first;
        fileToDisplay = File(pickedFile!.path.toString());
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  //Saat ve saat formatı ayarlamaları
  DateTime _selectedDate = DateTime.now();
  String? _startTime = DateFormat('hh:mm a').format(DateTime.now()).toString();
  int _selectedColor = 0;

  //Önceden hatırlatma seçimi kısmı için içeriğin ayarlanması
  int _selectedRemind = 5;
  List<int> remindList = [
    5,
    10,
    15,
    20,
  ];

  //Tekrar seçimi kısmı için içerğin ayarlanması
  String? _selectedRepeat = 'Yok';
  List<String> repeatList = [
    'Yok',
    'Günlük ',
    'Aylık',
    'Yıllık',
  ];

  @override
  Widget build(BuildContext context) {
    //Tarih ve tarih formatının ayarlandığı bölüm
    print(" starttime " + _startTime!);
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, now.minute, now.second);
    final format = DateFormat.jm();
    print(format.format(dt));
    print("add Task date: " + DateFormat.yMd().format(_selectedDate));

    //Sayfanın en dışında bulunan widget ağacı yapısı
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: _appBar(),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          //Sayfanın bottom overflow hatası almaması için SingleChildScrollView ayarlaması
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Hatırlatma Ekle başlığı
                Text(
                  "Hatırlatma Ekle",
                  style: headingTextStyle,
                ),
                SizedBox(
                  height: 8,
                ),
                //Hatırlatma başlığı için metin girdiğimiz alan
                InputField(
                  title: "Baslık",
                  hint: "Mobil programlama ödevi",
                  controller: _titleController,
                ),
                //Hatırlatma açıklaması için metin girdiğimiz alan
                InputField(
                    title: "Not",
                    hint: "Mobil programlama ödevini bitir (STRESLI)",
                    controller: _noteController),
                Row(
                  children: [
                    //Hatırlatma tarihi için tarih seçtiğimiz alan
                    Expanded(
                      child: InputField(
                        title: "Tarih",
                        hint: DateFormat.yMEd().format(_selectedDate),
                        widget: IconButton(
                          icon: (Icon(
                            Icons.calendar_month_sharp,
                            color: Colors.grey,
                          )),
                          //Tarih seçiminin kullanıcıdan alınması
                          onPressed: () {
                            _getDateFromUser();
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    //Hatırlatma alanı için saat seçimi alanı
                    Expanded(
                      child: InputField(
                        title: "Saat",
                        hint: _startTime,
                        widget: IconButton(
                          icon: (Icon(
                            Icons.alarm,
                            color: Colors.grey,
                          )),
                          //Saat seçiminin kullanıcıdan alınması
                          onPressed: () {
                            _getTimeFromUser(isStartTime: true);
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                //Telefon dosyasından seçeceğimiz zil sesinin görünümünün ayarlanması
                InputField(
                  title: "Zil Sesi",
                  hint: "$_fileName",
                  widget: Row(
                    children: [
                      Center(
                        child: isLoading
                            ? CircularProgressIndicator()
                            : TextButton(
                                //Tıklandığında telefon dosyasına yönlendirilmesi
                                onPressed: () {
                                  pickFile();
                                },
                                child: Text('Pick File'),
                              ),
                      ),
                      SizedBox(width: 6),
                    ],
                  ),
                ),

                //Önceden hatırlatma seçiminin, görünümünün ve işleyişinin ayarlanması
                InputField(
                  title: "Hatırlatma",
                  hint: "$_selectedRemind dakika önce",
                  widget: Row(
                    children: [
                      DropdownButton<String>(
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey,
                          ),
                          iconSize: 32,
                          elevation: 4,
                          dropdownColor: Colors.blueGrey,
                          style: TextStyle(color: Colors.white),
                          underline: Container(height: 0),
                          //Dropdown menüde yapılan seçimin kaydedilmesi
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedRemind = int.parse(newValue!);
                            });
                          },
                          items: remindList
                              .map<DropdownMenuItem<String>>((int value) {
                            return DropdownMenuItem<String>(
                              value: value.toString(),
                              child: Text(value.toString()),
                            );
                          }).toList()),
                      SizedBox(width: 6),
                    ],
                  ),
                ),

                //Günlük,haftalık,aylık tekrar seçiminin, görünümünün ve işleyişinin ayarlanması
                InputField(
                  title: "Tekrarla",
                  hint: _selectedRepeat,
                  widget: Row(
                    children: [
                      Container(
                        child: DropdownButton<String>(
                            dropdownColor: Colors.blueGrey,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey,
                            ),
                            iconSize: 32,
                            elevation: 4,
                            style: subTitleTextStle,
                            underline: Container(
                              height: 6,
                            ),
                            //Dropdown menüde yapılan seçimin kaydedilmesi
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedRepeat = newValue;
                              });
                            },
                            items: repeatList
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList()),
                      ),
                      SizedBox(width: 6),
                    ],
                  ),
                ),

                SizedBox(
                  height: 18.0,
                ),
                //Hatırlatma oluşturma butonunu
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _colorChips(),
                    MyButton(
                      label: "Oluştur",
                      onTap: () {
                        _validateInputs();
                      },
                    ),
                  ],
                ),

                SizedBox(
                  height: 30.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Hatırlatma ekleme alanının boş olması durumunda hata döndüren elegant bildirim.
  _validateInputs() {
    if (_titleController.text.isNotEmpty && _noteController.text.isNotEmpty) {
      _addTaskToDB();
      Get.back();
    } else if (_titleController.text.isEmpty || _noteController.text.isEmpty) {
      Get.snackbar(
        "Uyarı!",
        "Tüm alanların doldurulması gerekmektedir",
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      print("############ SOMETHING BAD HAPPENED #################");
    }
  }

  //Hatırlatmalar oluşturulduktan sonra değişkenlere atanıp veri tabanına kaydedilmesi
  _addTaskToDB() async {
    await _taskController.addTask(
      task: Task(
        note: _noteController.text,
        title: _titleController.text,
        date: DateFormat.yMd().format(_selectedDate),
        startTime: _startTime,
        remind: _selectedRemind,
        repeat: _selectedRepeat,
        color: _selectedColor,
        isCompleted: 0,
      ),
    );
  }

  //Hatırlatma kartının 3 farklı renginin ayarlanması
  _colorChips() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        "Renk",
        style: titleTextStle,
      ),
      SizedBox(
        height: 8,
      ),
      Wrap(
        children: List<Widget>.generate(
          3,
          (int index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: index == 0
                      ? primaryClr
                      : index == 1
                          ? pinkClr
                          : yellowClr,
                  child: index == _selectedColor
                      ? Center(
                          child: Icon(
                            Icons.done,
                            color: Colors.white,
                            size: 18,
                          ),
                        )
                      : Container(),
                ),
              ),
            );
          },
        ).toList(),
      ),
    ]);
  }
   //AppBar
  _appBar() {
    return AppBar(
        elevation: 0,
        //Hatırlatma sayfasına geri dönüş butonu
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Icon(Icons.arrow_back_ios, size: 24, color: primaryClr),
        ),
        //Çavuş köpek avatarı
        actions: [
          CircleAvatar(
            radius: 16,
            backgroundImage: AssetImage("lib/assets/sergeant.png"),
          ),
          SizedBox(
            width: 20,
          ),
        ]);
  }

  double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;

  //Kullanıcının saat seçimi yapmasını sağlayan fonksiyon
  _getTimeFromUser({required bool isStartTime}) async {
    var _pickedTime = await _showTimePicker();
    print(_pickedTime.format(context));
    String? _formatedTime = _pickedTime.format(context);
    print(_formatedTime);
    if (_pickedTime == null)
      print("İptal edildi");
    else if (isStartTime)
      setState(() {
        _startTime = _formatedTime;
      });
  }

  //Saat seçimi widgetının olduğu bölüm
  _showTimePicker() async {
    return showTimePicker(
      initialTime: TimeOfDay(
          hour: int.parse(_startTime!.split(":")[0]),
          minute: int.parse(_startTime!.split(":")[1].split(" ")[0])),
      initialEntryMode: TimePickerEntryMode.input,
      context: context,
    );
  }

  //Kullanıcının tarih seçimi yapmasını sağlayan widget6
  _getDateFromUser() async {
    final DateTime? _pickedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2015),
        lastDate: DateTime(2101));
    if (_pickedDate != null) {
      setState(() {
        _selectedDate = _pickedDate;
      });
    }
  }
}