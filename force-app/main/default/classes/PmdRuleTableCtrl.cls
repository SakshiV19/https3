public with sharing class PmdRuleTableCtrl {
    //PUBLIC

    @AuraEnabled(cacheable=true)
    public static List<PmdRule> getRulesFrom(Id extensionConfigId) {
        List<PmdRule> result = new List<PmdRule>();
        result = parse(getRulesetXml(extensionConfigId));
        return result;
    }

    //PRIVATE

    private static String getRulesetXml(Id extensionConfigId) {
        String result;

        List<ContentDocumentLink> fileLink = new ContentDocumentLinksSelector().byLinkedEntityIdAndTitle(new Set<Id>{ extensionConfigId }, 'ruleset');
        if(!fileLink.isEMpty()){
            result = new ContentVersionsSelector().byContentDocumentIdWithLatest(new Set<Id>{ fileLink[0].ContentDocumentId })[0].VersionData.toString();
        }

        return result;
    }

    private static List<PmdRule> parse(String xml) {
        List<PmdRule> rules = new List<PmdRule>();
        PmdRule rule;

        DOM.Document doc = new DOM.Document();
        doc.load(xml);

        for (Dom.XmlNode node : doc.getRootElement().getChildElements()) {
            if (node.getName() == 'rule') {
                rule = new PmdRule().processAttribute(node).processChilds(node);
                if (String.isNotBlank(rule.category) && String.isBlank(rule.name) && String.isBlank(rule.priority)) {
                    rule.priority('All');
                }

                rules.add(rule);
            }
        }

        return rules;
    }

    //INNER
    @TestVisible
    private class PmdRule {
        @AuraEnabled
        public String category;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String priority;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public String excludedRules;

        // BUILDER METHODS

        public PmdRule category(String category) {
            this.category = category;
            return this;
        }

        public PmdRule name(String name) {
            this.name = name;
            return this;
        }

        public PmdRule priority(String priority) {
            this.priority = priority;
            return this;
        }

        public PmdRule message(String message) {
            this.message = message;
            return this;
        }

        public PmdRule excludedRules(String excludedRules) {
            this.excludedRules = String.isBlank(this.excludedRules) ? excludedRules : ',' + excludedRules;
            return this;
        }

        public PmdRule processAttribute(Dom.XmlNode node) {
            String reference = node.getAttribute('ref', null);
            String name = node.getAttribute('name', null);
            String message = node.getAttribute('message', null);

            if (String.isNotBlank(reference)) {
                for (String ref : reference.split('/')) {
                    if (ref.containsIgnoreCase('.xml')) {
                        String category = ref.removeEnd('.xml');
                        category = category.subString(0, 1).ToUpperCase() + category.subString(1);
                        category(category);
                        name(reference.substringAfter(ref + '/'));
                    }
                }
            }

            if (String.isNotBlank(name)) {
                name(name);
            }

            if (String.isNotBlank(message)) {
                message(message);
            }

            return this;
        }

        public PmdRule processChilds(Dom.XmlNode node) {
            for (Dom.XmlNode innerNode : node.getChildElements()) {
                if (innerNode.getName() == 'priority') {
                    priority(innerNode.getText().trim());
                }

                if (innerNode.getName() == 'exclude') {
                    excludedRules(innerNode.getAttribute('name', null));
                }
            }

            return this;
        }
    }
}