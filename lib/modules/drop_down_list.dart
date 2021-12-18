import 'package:flutter/material.dart';

class DropDownList extends StatefulWidget {
  final List<String> items;
  final Function onChange;
  const DropDownList({required this.items, required this.onChange, Key? key})
      : super(key: key);

  @override
  _DropDownListState createState() => _DropDownListState();
}

class _DropDownListState extends State<DropDownList> {
  var dropdownValue = null;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Listener(
        onPointerDown: (_) =>
            FocusScope.of(context).unfocus(), //To avoide keyboard popping bug
        child: DropdownButton<String>(
          isExpanded: true,
          alignment: Alignment.center,
          value: dropdownValue ?? widget.items[0],
          // icon: const Icon(Icons.arrow_drop_down),
          elevation: 10,
          style: const TextStyle(
            color: Colors.black,
          ),
          underline: Container(
            height: 2,
            color: Colors.deepPurpleAccent,
          ),
          items: widget.items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            widget.onChange(newValue);
            setState(() {
              dropdownValue = newValue!;
            });
          },
        ),
      ),
    );
  }
}
