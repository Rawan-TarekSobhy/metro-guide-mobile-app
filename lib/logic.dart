import 'dart:collection';
import 'station.dart';


Map<String, dynamic> getDetails(
    List<String>? Route,
    Map<String, List<Station>> metroLines,
    String from,
    String to,
    int age,
    String disabled,
    ) {
  String? fromLine, toLine;

  // Find lines for from and to
  metroLines.forEach((lineName, stations) {
    if (stations.any((s) => s.name == from)) fromLine = lineName;
    if (stations.any((s) => s.name == to)) toLine = lineName;
  });

  // Find transfer station if any
  String? transferStation;
  if (fromLine != null && toLine != null && fromLine != toLine) {
    final stations1 = metroLines[fromLine]!;
    final stations2 = metroLines[toLine]!;

    for (var s in Route!) {
      if (stations1.any((st) => st.name == s) &&
          stations2.any((st) => st.name == s)) {
        transferStation = s;
        break;
      }
    }
  }

  // Direction
  String direction = '';
  if (fromLine != null) {
    final stations = metroLines[fromLine]!;
    final startIdx = stations.indexWhere((s) => s.name == Route!.first);
    final endIdx =
    stations.indexWhere((s) => s.name == (transferStation ?? Route!.last));

    direction = startIdx < endIdx
        ? '${stations.first.name} -> ${stations.last.name}'
        : '${stations.last.name} -> ${stations.first.name}';
  }

  if (toLine != null && transferStation != null) {
    final stations = metroLines[toLine]!;
    final startIdx = stations.indexWhere((s) => s.name == transferStation);
    final endIdx = stations.indexWhere((s) => s.name == Route!.last);

    direction += direction.isNotEmpty ? ' then ' : '';
    direction += startIdx < endIdx
        ? '${stations.first.name} -> ${stations.last.name}'
        : '${stations.last.name} -> ${stations.first.name}';
  }

  // Build the map<String, String>
  return {
    "Direction": direction.isNotEmpty ? direction : "Unknown",
    "Stations Count": "${Route!.length - 1}",
    "Time": "${(Route.length - 1) * 2} minutes",
    "Ticket Price":
    "${calculatePrice(Route.length - 1, age: age, disabled: disabled)} Pounds",
    "Route": Route.join(' -> '),
    "Lines": (fromLine != null && toLine != null)
        ? '${fromLine!}${fromLine != toLine ? ' -> $toLine' : ''}'
        : 'Unknown',
    "Transfer Station": transferStation ?? "None",
    "Color" : color(Route.length - 1),
  };
}



int calculatePrice(int count, {int age = 0, String disabled = 'no'}) {
  int price;
  if (disabled != 'yes') {
    if (count <= 9) {
      price = 8;
    } else if (count <= 16) {
      price = 10;
    } else if (count <= 23) {
      price= 15;
    } else {
      price= 20;
    }
  } else {
    return 5;
  }
  if (age > 60) {
    return (price * 0.5).toInt();
  }
  return price;
}

String color(int count) {
  String clr;
  if (count <= 9) {
    clr = 'yellow';
  } else if (count <= 16) {
    clr = 'green';
  } else if (count <= 23) {
    clr = 'pink';
  } else {
    clr = 'beige';
  }

  return clr;
}

Map<String, List<Station>> buildGraph(Map<String, List<Station>> lines) {
  final graph = <String, List<Station>>{};

  for (var stations in lines.values) {
    for (int i = 0; i < stations.length; i++) {
      graph.putIfAbsent(stations[i].name, () => []);

      if (i > 0) {
        graph[stations[i].name]!.add(stations[i - 1]);
        graph[stations[i - 1].name]!.add(stations[i]);
      }
    }
  }

  return graph;
}


List<String>? findShortestPath(
    Map<String, List<Station>> graph,
    String start,
    String end,
    ) {
  final queue = Queue<List<String>>();
  final visited = <String>{};

  queue.add([start]);
  visited.add(start);

  while (queue.isNotEmpty) {
    final path = queue.removeFirst();
    final current = path.last;

    if (current == end) {
      return path;
    }

    for (final neighbor in graph[current]!) {
      final neighborName = neighbor.name;

      if (!visited.contains(neighborName)) {
        visited.add(neighborName);
        queue.add([...path, neighborName]);
      }
    }
  }
  return null;
}
