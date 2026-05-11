import 'package:flutter_test/flutter_test.dart';
import 'package:integra_app/core/utils/crypto_utils.dart';

void main() {
  group('CryptoUtils Tests', () {
    test('deve gerar hash SHA256 para uma senha', () {
      // Arrange
      const password = 'senha123';

      // Act
      final hash = CryptoUtils.hashPassword(password);

      // Assert
      expect(hash, isNotEmpty);
      expect(hash.length, 64); // SHA256 gera hash de 64 caracteres hexadecimais
    });

    test('deve gerar o mesmo hash para a mesma senha', () {
      // Arrange
      const password = 'senha123';

      // Act
      final hash1 = CryptoUtils.hashPassword(password);
      final hash2 = CryptoUtils.hashPassword(password);

      // Assert
      expect(hash1, equals(hash2));
    });

    test('deve gerar hashes diferentes para senhas diferentes', () {
      // Arrange
      const password1 = 'senha123';
      const password2 = 'senha456';

      // Act
      final hash1 = CryptoUtils.hashPassword(password1);
      final hash2 = CryptoUtils.hashPassword(password2);

      // Assert
      expect(hash1, isNot(equals(hash2)));
    });

    test('deve ser case-sensitive', () {
      // Arrange
      const password1 = 'Senha123';
      const password2 = 'senha123';

      // Act
      final hash1 = CryptoUtils.hashPassword(password1);
      final hash2 = CryptoUtils.hashPassword(password2);

      // Assert
      expect(hash1, isNot(equals(hash2)));
    });

    test('deve lidar com senhas vazias', () {
      // Arrange
      const password = '';

      // Act
      final hash = CryptoUtils.hashPassword(password);

      // Assert
      expect(hash, isNotEmpty);
      expect(hash.length, 64);
    });

    test('deve lidar com senhas com caracteres especiais', () {
      // Arrange
      const password = 'S3nh@!#\$%&*()_+-=[]{}|;:,.<>?';

      // Act
      final hash = CryptoUtils.hashPassword(password);

      // Assert
      expect(hash, isNotEmpty);
      expect(hash.length, 64);
    });

    test('deve lidar com senhas com caracteres unicode', () {
      // Arrange
      const password = 'senha123áéíóúãõç';

      // Act
      final hash = CryptoUtils.hashPassword(password);

      // Assert
      expect(hash, isNotEmpty);
      expect(hash.length, 64);
    });

    test('deve gerar hash conhecido para senha conhecida', () {
      // Arrange
      const password = 'test';
      const expectedHash =
          '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08';

      // Act
      final hash = CryptoUtils.hashPassword(password);

      // Assert
      expect(hash, equals(expectedHash));
    });

    test('deve lidar com senhas muito longas', () {
      // Arrange
      final password = 'a' * 10000;

      // Act
      final hash = CryptoUtils.hashPassword(password);

      // Assert
      expect(hash, isNotEmpty);
      expect(hash.length, 64);
    });
  });
}
