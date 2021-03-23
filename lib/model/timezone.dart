class Timezone {
  final String value;
  final String name;

  Timezone(this.value, this.name);

  Timezone.fromJson(Map<String, dynamic> json)
      : value = json['value'],
        name = json['name'];
}