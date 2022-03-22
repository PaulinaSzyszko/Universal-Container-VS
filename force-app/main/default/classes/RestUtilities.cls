public with sharing class RestUtilities {

    public static Boolean isRestApiContext() {
        return RestContext.request != null;
    }
    public with sharing class UrlParameterBuilder {

        private List<String> paramsList;

        public UrlParameterBuilder() {
            this.paramsList = new List<String>();
        }

        public UrlParameterBuilder addParam(String paramName, String paramValue) {
            String result = this.paramsList.isEmpty() ? '?' : '';
            result += constructParameterForEndpoint(paramName, paramValue);
            this.paramsList.add(result);
            return this;
        }

        private String constructParameterForEndpoint(String paramName, String paramValue) {
            return String.join(new List<String>{
                    paramName, paramValue
            }, '=');
        }

        public String build() {
            return String.join(this.paramsList, '&');
        }

    }
}