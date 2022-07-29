class DrinkAlreadyExistsException implements Exception {
    
    @override
    String toString() {
        return "A drink with the given name already exists.";
    }
}