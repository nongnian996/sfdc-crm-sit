public class Relationship {
    public String name;
    public String title;
    public String type;
    public String nodeId;
    public String className;
    public String isActive;
    public List<Children_X> children;

    public class Children_X {
        public String name;
        public String title;
        public String type;
        public String nodeId;
        public String className;
        public String isActive;
        public List<Children_Y> children;
    }

    public class Children_Y {
        public String name;
        public String title;
        public String type;
        public String nodeId;
        public String className;
        public String isActive;
        public List<Children> children;
    }

    public class Children {
        public String name;
        public String title;
        public String type;
        public String nodeId;
        public String isActive;
        public String className;
    }

    
    public static Relationship parse(String json) {
        return (Relationship) System.JSON.deserialize(json, Relationship.class);
    }
}