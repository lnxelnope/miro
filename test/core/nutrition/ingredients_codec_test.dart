import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:miro_hybrid/core/nutrition/ingredients_codec.dart';
import 'package:miro_hybrid/core/nutrition/ingredients_models.dart';

void main() {
  group('parseIngredientsJson', () {
    test('null and empty → empty kind, no throw', () {
      final a = parseIngredientsJson(null);
      expect(a.kind, IngredientsJsonKind.empty);
      expect(a.documentV2, isNull);

      final b = parseIngredientsJson('');
      expect(b.kind, IngredientsJsonKind.empty);
    });

    test('invalid JSON → invalidJson, no throw', () {
      final r = parseIngredientsJson('{not json');
      expect(r.kind, IngredientsJsonKind.invalidJson);
    });
  });

  group('legacy + schemaVersion', () {
    test('legacy list serializes to v2 string with schemaVersion 2', () {
      const legacy = '[{"name":"Rice","name_en":null,"amount":1,"unit":"bowl",'
          '"calories":200,"protein":4,"carbs":45,"fat":0.5}]';
      final parsed = parseIngredientsJson(legacy);
      expect(parsed.kind, IngredientsJsonKind.legacyList);
      expect(parsed.documentV2, isNotNull);

      final out = serializeIngredientsV2(parsed.documentV2!);
      expect(out, contains('schemaVersion'));
      expect(out, contains('mainIngredients'));
      expect(out, contains('"schemaVersion":2'));
    });

    test('v2 round-trip preserves main count and rollup totals', () {
      final doc = IngredientsDocumentV2(mainIngredients: [
        IngredientNode(
          name: 'Main',
          amount: 1,
          unit: 'serving',
          calories: 50,
          protein: 5,
          carbs: 6,
          fat: 7,
          subIngredients: const [
            IngredientNode(
              name: 'a',
              amount: 1,
              unit: 'g',
              calories: 20,
              protein: 2,
              carbs: 2,
              fat: 2,
            ),
            IngredientNode(
              name: 'b',
              amount: 1,
              unit: 'g',
              calories: 30,
              protein: 3,
              carbs: 4,
              fat: 5,
            ),
          ],
        ),
      ]);
      final s = serializeIngredientsV2(doc);
      final again = parseIngredientsJson(s);
      expect(again.kind, IngredientsJsonKind.version2);
      expect(again.documentV2!.mainIngredients.length, 1);
      final roll = recomputeEntryRollup(doc: again.documentV2!);
      expect(roll.calories, closeTo(50, 0.001));
      expect(roll.protein, closeTo(5, 0.001));
    });
  });

  group('recomputeEntryRollup + fiber/sugar/sodium', () {
    test('two subs → entry macros equal hand sum', () {
      final doc = IngredientsDocumentV2(mainIngredients: [
        IngredientNode(
          name: 'M',
          amount: 1,
          unit: 'g',
          calories: 0,
          protein: 0,
          carbs: 0,
          fat: 0,
          subIngredients: const [
            IngredientNode(
              name: 's1',
              amount: 1,
              unit: 'g',
              calories: 10,
              protein: 1,
              carbs: 2,
              fat: 3,
            ),
            IngredientNode(
              name: 's2',
              amount: 1,
              unit: 'g',
              calories: 5,
              protein: 0.5,
              carbs: 1,
              fat: 0.25,
            ),
          ],
        ),
      ]);
      final r = recomputeEntryRollup(doc: doc);
      expect(r.calories, 15);
      expect(r.protein, closeTo(1.5, 1e-9));
      expect(r.carbs, 3);
      expect(r.fat, closeTo(3.25, 1e-9));
    });

    test('partial micro on subs preserves entry fiber/sugar/sodium (D-08b)', () {
      final doc = IngredientsDocumentV2(mainIngredients: [
        IngredientNode(
          name: 'M',
          amount: 1,
          unit: 'g',
          calories: 10,
          protein: 1,
          carbs: 1,
          fat: 1,
          subIngredients: const [
            IngredientNode(
              name: 'a',
              amount: 1,
              unit: 'g',
              calories: 10,
              protein: 1,
              carbs: 1,
              fat: 1,
              fiber: 2,
            ),
            IngredientNode(
              name: 'b',
              amount: 1,
              unit: 'g',
              calories: 0,
              protein: 0,
              carbs: 0,
              fat: 0,
            ),
          ],
        ),
      ]);
      final r = recomputeEntryRollup(
        doc: doc,
        entryFiber: 9,
        entrySugar: 8,
        entrySodium: 7,
      );
      expect(r.fiber, 9);
      expect(r.sugar, 8);
      expect(r.sodium, 7);
    });

    test('all subs have fiber → sum fiber', () {
      final doc = IngredientsDocumentV2(mainIngredients: [
        IngredientNode(
          name: 'M',
          amount: 1,
          unit: 'g',
          calories: 10,
          protein: 1,
          carbs: 1,
          fat: 1,
          subIngredients: const [
            IngredientNode(
              name: 'a',
              amount: 1,
              unit: 'g',
              calories: 5,
              protein: 0.5,
              carbs: 0.5,
              fat: 0.5,
              fiber: 2,
            ),
            IngredientNode(
              name: 'b',
              amount: 1,
              unit: 'g',
              calories: 5,
              protein: 0.5,
              carbs: 0.5,
              fat: 0.5,
              fiber: 3,
            ),
          ],
        ),
      ]);
      final r = recomputeEntryRollup(
        doc: doc,
        entryFiber: 99,
        entrySugar: null,
        entrySodium: null,
      );
      expect(r.fiber, 5);
    });
  });

  group('flattenAiIngredientRoots', () {
    bool noNestedSubs(IngredientsDocumentV2 d) {
      for (final m in d.mainIngredients) {
        for (final s in m.subIngredients) {
          if (s.subIngredients.isNotEmpty) return false;
        }
      }
      return true;
    }

    test('flatten depth >= 3: no nested subIngredients under subs', () {
      final roots = <Map<String, dynamic>>[
        {
          'name': 'Dish',
          'amount': 1,
          'unit': 'serving',
          'calories': 300,
          'protein': 20,
          'carbs': 30,
          'fat': 10,
          'sub_ingredients': [
            {
              'name': 'Parent',
              'amount': 1,
              'unit': 'g',
              'calories': 300,
              'protein': 20,
              'carbs': 30,
              'fat': 10,
              'sub_ingredients': [
                {
                  'name': 'Leaf1',
                  'amount': 1,
                  'unit': 'g',
                  'calories': 100,
                  'protein': 5,
                  'carbs': 10,
                  'fat': 2,
                },
                {
                  'name': 'Leaf2',
                  'amount': 1,
                  'unit': 'g',
                  'calories': 200,
                  'protein': 15,
                  'carbs': 20,
                  'fat': 8,
                },
              ],
            },
          ],
        },
      ];
      final flat = flattenAiIngredientRoots(roots);
      expect(noNestedSubs(flat), isTrue);
      expect(flat.mainIngredients.length, 1);
      final subs = flat.mainIngredients.first.subIngredients;
      expect(subs.length, 2);
      // Calories redistributed from parent budget; sum should match root main total.
      var sum = 0.0;
      for (final s in subs) {
        sum += s.calories;
      }
      expect(sum, closeTo(300, 0.01));
    });

    test('flatten leaves sum calories within root budget', () {
      final roots = <Map<String, dynamic>>[
        jsonDecode(
          '{"name":"R","amount":1,"unit":"serving","calories":150,"protein":10,"carbs":10,"fat":5,'
          '"sub_ingredients":[{"name":"Mid","amount":1,"unit":"g","calories":150,"protein":10,"carbs":10,"fat":5,'
          '"sub_ingredients":[{"name":"L","amount":1,"unit":"g","calories":150,"protein":10,"carbs":10,"fat":5}]}]}',
        ) as Map<String, dynamic>,
      ];
      final flat = flattenAiIngredientRoots(roots);
      expect(flat.mainIngredients.first.subIngredients.length, 1);
      expect(
        flat.mainIngredients.first.subIngredients.first.calories,
        closeTo(150, 0.01),
      );
    });
  });
}
