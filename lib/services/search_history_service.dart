import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SearchHistoryService {
  static const String _key = 'search_history';
  static const int _maxHistoryItems = 10;

  Future<List<String>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_key) ?? [];
    return history;
  }

  Future<void> addSearchQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_key) ?? [];
    
    // Remove the query if it already exists to avoid duplicates
    history.remove(query);
    
    // Add the new query to the beginning of the list
    history.insert(0, query);
    
    // Limit the history to _maxHistoryItems
    if (history.length > _maxHistoryItems) {
      history = history.sublist(0, _maxHistoryItems);
    }
    
    await prefs.setStringList(_key, history);
  }

  Future<void> clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
