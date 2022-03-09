/**
 * Created by SZYSZPA on 10-Feb-22.
 */

public with sharing class SoqlBuilder {

    private String type = 'SELECT ';
    private Map<String, String> wherex = new Map<String, String>();
    private Map<String, String> operators = new Map<String, String>();
    private Set<String> fields = new Set<String>();
    private String fromx;

    public SoqlBuilder fromx(String fromx) {
        this.fromx = fromx;
        return this;
    }

    public SoqlBuilder addFields(Set<String> fields) {
        this.fields = fields;
        return this;
    }
    public SoqlBuilder addField(String field) {
        this.fields.add(field);
        return this;
    }

    public SoqlBuilder addWhere(String name, String value, String operator) {

        if (value != null && String.isNotEmpty(value)) {
            this.wherex.put(name, '\'' + value + '\'');
            this.operators.put(name, operator);
        }
        return this;
    }
    public SoqlBuilder addWhere(String name, Date value, String operator) {

        if (value != null) {
            this.wherex.put(name, String.valueOf(value).removeEnd(' 00:00:00'));
            this.operators.put(name, operator);
        }
        return this;
    }

    public String build() {

        String query = type;

        for (String field : fields) {
            query += field + ', ';
        }

        query = query.removeEnd(', ');
        query += ' FROM ' + fromx;
        query += ' WHERE ';

        for (String name : wherex.keySet()) {
            query += name + ' ' + operators.get(name) + ' ' + wherex.get(name) + ' AND ';
        }

        query = query.removeEnd(' AND ');

        return query;
    }

}