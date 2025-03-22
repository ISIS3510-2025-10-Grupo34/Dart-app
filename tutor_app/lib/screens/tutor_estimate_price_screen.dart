import 'package:flutter/material.dart';
import 'add_course_screen.dart';

class TutorEstimatePriceScreen extends StatefulWidget {
  const TutorEstimatePriceScreen({super.key});

  @override
  State<TutorEstimatePriceScreen> createState() =>
      _TutorEstimatePriceScreenState();
}

class _TutorEstimatePriceScreenState extends State<TutorEstimatePriceScreen> {
  String _sessionType = 'Pre-exam session';
  final TextEditingController _timeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'TutorApp',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título principal
            const Text(
              "How much should you be paid?",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),

            // Subtítulo
            Text(
              "Our models were trained with the historical info of all the bookings.",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 30),

            // Etiqueta "Time"
            const Text(
              "Time",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 5),

            // Campo de texto para el tiempo de la sesión
            TextField(
              controller: _timeController,
              decoration: InputDecoration(
                hintText: "Time in hours of the session",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // Opciones de tipo de sesión (Pre-exam / Normal)
            Column(
              children: [
                RadioListTile<String>(
                  title: const Text(
                    "Pre-exam session",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  value: 'Pre-exam session',
                  groupValue: _sessionType,
                  onChanged: (value) {
                    setState(() {
                      _sessionType = value!;
                    });
                  },
                  activeColor: Colors.blue,
                ),
                RadioListTile<String>(
                  title: const Text(
                    "Normal session",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  value: 'Normal session',
                  groupValue: _sessionType,
                  onChanged: (value) {
                    setState(() {
                      _sessionType = value!;
                    });
                  },
                  activeColor: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Información adicional sobre la experiencia y calificaciones
            Text(
              "*Your seniority in TutorApp and the grades you have received will be taken into account.",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),

            // Botón para predecir precio
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _predictPrice();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Predict price",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FUNCION PARA MOSTRAR ALERTDIALOG CON ESTILO PERSONALIZADO
  void _predictPrice() {
    String time = _timeController.text;

    if (time.isEmpty || double.tryParse(time) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid number."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    double hours = double.parse(time);
    if (hours <= 0 || hours > 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Session time must be between 0 and 12 hours."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Definir precios base en COP
    double pricePerHour =
        _sessionType == 'Pre-exam session' ? 35000.0 : 20000.0;

    double totalPrice = hours * pricePerHour;

    // Mostrar el resultado en una ventana emergente personalizada
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.grey[200],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today, size: 40, color: Colors.black),
                const SizedBox(height: 10),
                const Text(
                  "Your ideal price is:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "${totalPrice.toStringAsFixed(0)} COP",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(totalPrice.toStringAsFixed(0)); // Retornar el precio
                    },
                    child: const Text(
                      "Ok",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((value) {
      if (value != null) {
        // Si el valor no es nulo, pasamos a la pantalla de AddCourse
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddCourseScreen(initialPrice: value),
          ),
        );
      }
    });
  }

}
