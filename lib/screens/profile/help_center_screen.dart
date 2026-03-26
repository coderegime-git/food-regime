// lib/screens/profile/help_center_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:food_delivery_app/model/static_page_data.dart';
import 'package:food_delivery_app/utils/api_service.dart';
import 'package:food_delivery_app/widgets/app_loader.dart';

class HelpCenterScreen extends StatefulWidget {
  final String page;

  const HelpCenterScreen({super.key, required this.page});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final apiService = ApiService();
  late StaticPageData staticPageData;
  bool isLoad = true;

  @override
  void initState() {
    super.initState();
    getStaticPage();
  }

  getStaticPage() async {
    staticPageData = await apiService.getStaticPage(page: widget.page);
    setState(() {
      isLoad = false;
    });
  }

  String formatText(String text) {
    String html = text;

    // Headings
    html = html.replaceAllMapped(
      RegExp(r'## (.*)'),
      (match) => '<h2>${match[1]}</h2>',
    );

    html = html.replaceAllMapped(
      RegExp(r'### (.*)'),
      (match) => '<h3>${match[1]}</h3>',
    );

    // Bullet points
    html = html.replaceAllMapped(
      RegExp(r'\* (.*)'),
      (match) => '<li>${match[1]}</li>',
    );

    // Horizontal line
    html = html.replaceAll('---', '<hr>');

    // Line breaks
    html = html.replaceAll('\n', '<br>');

    return html;
  }

  @override
  Widget build(BuildContext context) {
    return isLoad
        ? AppDefaultLoader(loading: isLoad)
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
                backgroundColor: Colors.white,
                shadowColor: Colors.grey.shade300,
                leading: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const Icon(
                    CupertinoIcons.back,
                    color: Colors.black,
                  ),
                ),
                title: Text(
                  staticPageData.data!.first!.title ?? "",
                  style: const TextStyle(color: Colors.black),
                )),
            body: Center(
                child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: staticPageData.data!.length,
              itemBuilder: (context, index) {
                final data = staticPageData.data![index];

                return HtmlWidget(
                  formatText(data.content ?? "") ?? "",
                  textStyle: const TextStyle(color: Colors.black),
                );
              },
            )),
          );
  }
}
