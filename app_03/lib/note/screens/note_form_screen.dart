import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/note.dart';
import '../database/note_database_helper.dart';
import '../utils/priority_utils.dart';

class NoteFormScreen extends StatefulWidget {
  final int? noteId;

  const NoteFormScreen({Key? key, this.noteId}) : super(key: key);

  @override
  _NoteFormScreenState createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tieuDeController = TextEditingController();
  final _noiDungController = TextEditingController();
  final _theController = TextEditingController();
  final NoteDatabaseHelper _csdlHelper = NoteDatabaseHelper();

  int _uuTien = 2; // Mặc định: Trung bình
  String? _mauSac;
  List<String> _dsThe = [];
  bool _dangTai = false;
  bool _dangChinhSua = false;
  Note? _ghiChuGoc;

  @override
  void initState() {
    super.initState();
    if (widget.noteId != null) {
      _dangChinhSua = true;
      _taiGhiChu();
    }
  }

  Future<void> _taiGhiChu() async {
    setState(() {
      _dangTai = true;
    });

    final ghiChu = await _csdlHelper.getNoteById(widget.noteId!);
    if (ghiChu != null) {
      _ghiChuGoc = ghiChu;
      _tieuDeController.text = ghiChu.title;
      _noiDungController.text = ghiChu.content;
      _uuTien = ghiChu.priority;
      _mauSac = ghiChu.color;
      _dsThe = ghiChu.tags ?? [];
    }

    setState(() {
      _dangTai = false;
    });
  }

  @override
  void dispose() {
    _tieuDeController.dispose();
    _noiDungController.dispose();
    _theController.dispose();
    super.dispose();
  }

  void _themThe() {
    final the = _theController.text.trim();
    if (the.isNotEmpty && !_dsThe.contains(the)) {
      setState(() {
        _dsThe.add(the);
        _theController.clear();
      });
    }
  }

  void _xoaThe(String the) {
    setState(() {
      _dsThe.remove(the);
    });
  }

  void _chonMau() {
    Color mauHienTai = _mauSac != null
        ? Color(int.parse(_mauSac!.replaceAll('#', '0xFF')))
        : Colors.blue;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn màu'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: mauHienTai,
            onColorChanged: (mau) {
              mauHienTai = mau;
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _mauSac = '#${mauHienTai.value.toRadixString(16).substring(2)}';
              });
              Navigator.pop(context);
            },
            child: const Text('Chọn'),
          ),
        ],
      ),
    );
  }

  Future<void> _luuGhiChu() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _dangTai = true;
      });

      try {
        if (_dangChinhSua && _ghiChuGoc != null) {
          final capNhat = _ghiChuGoc!.copyWith(
            title: _tieuDeController.text,
            content: _noiDungController.text,
            priority: _uuTien,
            tags: _dsThe,
            color: _mauSac,
          );

          await _csdlHelper.updateNote(capNhat);
        } else {
          final moi = Note.create(
            title: _tieuDeController.text,
            content: _noiDungController.text,
            priority: _uuTien,
            tags: _dsThe.isNotEmpty ? _dsThe : null,
            color: _mauSac,
          );

          await _csdlHelper.insertNote(moi);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_dangChinhSua
                  ? 'Cập nhật ghi chú thành công'
                  : 'Tạo ghi chú thành công'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _dangTai = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_dangChinhSua ? 'Chỉnh sửa ghi chú' : 'Tạo ghi chú'),
      ),
      body: _dangTai
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề
              TextFormField(
                controller: _tieuDeController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tiêu đề';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Nội dung
              TextFormField(
                controller: _noiDungController,
                decoration: const InputDecoration(
                  labelText: 'Nội dung',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập nội dung';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Ưu tiên
              const Text(
                'Mức độ ưu tiên:',
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Radio<int>(
                    value: 1,
                    groupValue: _uuTien,
                    onChanged: (value) {
                      setState(() {
                        _uuTien = value!;
                      });
                    },
                  ),
                  const Text('Thấp'),
                  Radio<int>(
                    value: 2,
                    groupValue: _uuTien,
                    onChanged: (value) {
                      setState(() {
                        _uuTien = value!;
                      });
                    },
                  ),
                  const Text('Trung bình'),
                  Radio<int>(
                    value: 3,
                    groupValue: _uuTien,
                    onChanged: (value) {
                      setState(() {
                        _uuTien = value!;
                      });
                    },
                  ),
                  const Text('Cao'),
                ],
              ),
              const SizedBox(height: 16),

              // Màu sắc
              Row(
                children: [
                  const Text(
                    'Màu sắc:',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: _chonMau,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _mauSac != null
                            ? Color(int.parse(
                            _mauSac!.replaceAll('#', '0xFF')))
                            : PriorityUtils.getPriorityColor(_uuTien),
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _chonMau,
                    child: const Text('Đổi màu'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Thẻ
              const Text(
                'Thẻ:',
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _theController,
                      decoration: const InputDecoration(
                        hintText: 'Thêm thẻ',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _themThe(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _themThe,
                    child: const Text('Thêm'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _dsThe
                    .map((the) => Chip(
                  label: Text(the),
                  deleteIcon:
                  const Icon(Icons.close, size: 18),
                  onDeleted: () => _xoaThe(the),
                ))
                    .toList(),
              ),
              const SizedBox(height: 24),

              // Nút lưu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _luuGhiChu,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _dangChinhSua ? 'Cập nhật ghi chú' : 'Lưu ghi chú',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
