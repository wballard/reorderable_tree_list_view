import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/src/models/tree_path.dart';

void main() {
  group('TreePath', () {
    group('generateIntermediatePaths', () {
      test('generates all parent paths for a deep path', () {
        final Uri path = Uri.parse('file://var/data/readme.txt');
        final List<Uri> intermediatePaths = TreePath.generateIntermediatePaths(path);
        
        expect(intermediatePaths, equals(<Uri>[
          Uri.parse('file://'),
          Uri.parse('file://var'),
          Uri.parse('file://var/data'),
        ]));
      });
      
      test('returns empty list for root path', () {
        final Uri path = Uri.parse('file://');
        final List<Uri> intermediatePaths = TreePath.generateIntermediatePaths(path);
        
        expect(intermediatePaths, isEmpty);
      });
      
      test('generates correct paths for single segment', () {
        final Uri path = Uri.parse('file://var');
        final List<Uri> intermediatePaths = TreePath.generateIntermediatePaths(path);
        
        expect(intermediatePaths, equals(<Uri>[
          Uri.parse('file://'),
        ]));
      });
      
      test('handles different URI schemes', () {
        final Uri path = Uri.parse('http://example.com/api/v1/users');
        final List<Uri> intermediatePaths = TreePath.generateIntermediatePaths(path);
        
        expect(intermediatePaths, equals(<Uri>[
          Uri.parse('http://example.com'),
          Uri.parse('http://example.com/api'),
          Uri.parse('http://example.com/api/v1'),
        ]));
      });
    });
    
    group('calculateDepth', () {
      test('calculates depth for various paths', () {
        expect(TreePath.calculateDepth(Uri.parse('file://')), equals(0));
        expect(TreePath.calculateDepth(Uri.parse('file://var')), equals(1));
        expect(TreePath.calculateDepth(Uri.parse('file://var/data')), equals(2));
        expect(TreePath.calculateDepth(Uri.parse('file://var/data/readme.txt')), equals(3));
      });
      
      test('handles paths with empty segments', () {
        expect(TreePath.calculateDepth(Uri.parse('file://var//data')), equals(2));
        expect(TreePath.calculateDepth(Uri.parse('file://var/')), equals(1));
      });
    });
    
    group('getDisplayName', () {
      test('returns scheme for root paths', () {
        expect(TreePath.getDisplayName(Uri.parse('file://')), equals('file://'));
        expect(TreePath.getDisplayName(Uri.parse('http://example.com')), equals('http://example.com'));
        expect(TreePath.getDisplayName(Uri.parse('custom://')), equals('custom://'));
      });
      
      test('returns last segment for non-root paths', () {
        expect(TreePath.getDisplayName(Uri.parse('file://var')), equals('var'));
        expect(TreePath.getDisplayName(Uri.parse('file://var/data')), equals('data'));
        expect(TreePath.getDisplayName(Uri.parse('file://var/data/readme.txt')), equals('readme.txt'));
      });
      
      test('handles trailing slashes', () {
        expect(TreePath.getDisplayName(Uri.parse('file://var/')), equals('var'));
        expect(TreePath.getDisplayName(Uri.parse('file://var/data/')), equals('data'));
      });
      
      test('handles special characters in names', () {
        expect(TreePath.getDisplayName(Uri.parse('file://my%20folder')), equals('my folder'));
        expect(TreePath.getDisplayName(Uri.parse('file://special%2Bchar')), equals('special+char'));
      });
    });
    
    group('getParentPath', () {
      test('returns null for root paths', () {
        expect(TreePath.getParentPath(Uri.parse('file://')), isNull);
        expect(TreePath.getParentPath(Uri.parse('http://example.com')), isNull);
      });
      
      test('returns parent for non-root paths', () {
        expect(TreePath.getParentPath(Uri.parse('file://var')), equals(Uri.parse('file://')));
        expect(TreePath.getParentPath(Uri.parse('file://var/data')), equals(Uri.parse('file://var')));
        expect(TreePath.getParentPath(Uri.parse('file://var/data/readme.txt')), equals(Uri.parse('file://var/data')));
      });
      
      test('handles trailing slashes', () {
        expect(TreePath.getParentPath(Uri.parse('file://var/')), equals(Uri.parse('file://')));
        expect(TreePath.getParentPath(Uri.parse('file://var/data/')), equals(Uri.parse('file://var')));
      });
    });
    
    group('isAncestorOf', () {
      test('returns true for direct ancestors', () {
        expect(TreePath.isAncestorOf(
          Uri.parse('file://'),
          Uri.parse('file://var'),
        ), isTrue);
        
        expect(TreePath.isAncestorOf(
          Uri.parse('file://var'),
          Uri.parse('file://var/data'),
        ), isTrue);
        
        expect(TreePath.isAncestorOf(
          Uri.parse('file://var/data'),
          Uri.parse('file://var/data/readme.txt'),
        ), isTrue);
      });
      
      test('returns true for indirect ancestors', () {
        expect(TreePath.isAncestorOf(
          Uri.parse('file://'),
          Uri.parse('file://var/data/readme.txt'),
        ), isTrue);
        
        expect(TreePath.isAncestorOf(
          Uri.parse('file://var'),
          Uri.parse('file://var/data/readme.txt'),
        ), isTrue);
      });
      
      test('returns false for non-ancestors', () {
        expect(TreePath.isAncestorOf(
          Uri.parse('file://var'),
          Uri.parse('file://usr'),
        ), isFalse);
        
        expect(TreePath.isAncestorOf(
          Uri.parse('file://var/data'),
          Uri.parse('file://var/config'),
        ), isFalse);
        
        expect(TreePath.isAncestorOf(
          Uri.parse('file://var'),
          Uri.parse('file://'),
        ), isFalse); // Child cannot be ancestor of parent
      });
      
      test('returns false for same paths', () {
        expect(TreePath.isAncestorOf(
          Uri.parse('file://var'),
          Uri.parse('file://var'),
        ), isFalse);
      });
      
      test('returns false for different schemes', () {
        expect(TreePath.isAncestorOf(
          Uri.parse('file://var'),
          Uri.parse('http://var/data'),
        ), isFalse);
      });
    });
  });
}