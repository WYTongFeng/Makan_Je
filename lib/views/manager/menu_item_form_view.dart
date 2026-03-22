import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/menu_item_model.dart';
import '../../view_models/manager_view_model.dart';

class MenuItemFormView extends StatefulWidget {
  const MenuItemFormView({Key? key}) : super(key: key);

  @override
  State<MenuItemFormView> createState() => _MenuItemFormViewState();
}

class _MenuItemFormViewState extends State<MenuItemFormView> {
  final _formKey = GlobalKey<FormState>();
  final ManagerViewModel _viewModel = ManagerViewModel();
  
  final _nameController = TextEditingController();
  final _nameMyController = TextEditingController(); // Added Malay Name
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descController = TextEditingController();
  final _imageController = TextEditingController();
  final _remarkController = TextEditingController(); // Added Remark/Customization

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _nameMyController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _descController.dispose();
    _imageController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    final newItem = MenuItemModel(
      itemId: '', // Handled by Firestore via auto-generated ID
      nameEn: _nameController.text.trim(),
      nameMy: _nameMyController.text.trim(),
      description: _descController.text.trim(),
      price: double.tryParse(_priceController.text) ?? 0.0,
      category: _categoryController.text.trim(),
      imageUrl: _imageController.text.trim(),
      isSoldOut: false,
      allergens: [],
      customizationOptions: _remarkController.text.trim().isEmpty 
          ? [] 
          : _remarkController.text.split(',').map((e) => e.trim()).toList(),
    );

    try {
      await _viewModel.addNewItem(newItem);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menu Item Added successfully!', style: TextStyle(color: Colors.white)), backgroundColor: AppTheme.primaryOrange)
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e', style: const TextStyle(color: Colors.white)), backgroundColor: AppTheme.darkRed)
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.paleYellow,
      appBar: AppBar(
        title: const Text('Add Menu Item', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.darkRed,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(_nameController, 'Item Name (English)', Icons.fastfood),
              const SizedBox(height: 16),
              _buildTextField(_nameMyController, 'Item Name (Malay/Chinese)', Icons.translate),
              const SizedBox(height: 16),
              _buildTextField(_remarkController, 'Remarks/Options (Split by comma)', Icons.edit_note, hint: 'No Chili, No Onion, Extra Ice...'),
              const SizedBox(height: 16),
              _buildTextField(_priceController, 'Price (RM)', Icons.attach_money, isNumber: true),
              const SizedBox(height: 16),
              _buildTextField(_categoryController, 'Category (e.g. Main, Drink)', Icons.category),
              const SizedBox(height: 16),
              _buildTextField(_descController, 'Description', Icons.description, maxLines: 2),
              const SizedBox(height: 16),
              _buildTextField(_imageController, 'Image Path (e.g. assets/images/food.png)', Icons.image),
              const SizedBox(height: 32),
              
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Item', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, int maxLines = 1, String? hint}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: Icon(icon, color: AppTheme.primaryOrange),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          if (label.contains('Optional')) return null;
          return 'Please enter $label';
        }
        if (isNumber && double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }
}
