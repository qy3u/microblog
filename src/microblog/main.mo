import Iter "mo:base/Iter";
import List "mo:base/List";
import Principal "mo:base/Principal";
import Time "mo:base/Time";


actor {
    public type Message = {
        content: Text;
        time: Time.Time;
    };

    public type Microblog = actor {
       follow: shared(Principal) -> async();
       follows: shared query () -> async [Principal];
       post: shared (Text) -> async();
       posts: shared query (Time.Time) -> async [Message];
       timeline: shared(Time.Time) -> async [Message];
    };

    stable var followed: List.List<Principal> = List.nil();

    public shared func follow(id: Principal): async() {
        followed := List.push(id, followed)
    };

    public shared query func follows(): async [Principal] {
        List.toArray(followed)
    };

    stable var messages: List.List<Message> = List.nil();

    public shared(msg) func post(text: Text): async() {
        assert(Principal.toText(msg.caller) == "jndb5-qn4yq-dw6sq-vq3en-xzaqn-4mxu4-2zchg-z6czd-vmiuu-tdems-vqe");

        var now: Time.Time = Time.now();
        var blog: Message =  {
            content = text;
            time = now;
        };

        messages := List.push(blog, messages)
    };

    func posts(since: Time.Time): async [Message] {
        let filter = func(m: Message): Bool {
            m.time > since
        };

        List.toArray(List.filter<Message>(messages, filter))
    };

    public shared func timeline(since: Time.Time): async [Message] {
        var all : List.List<Message> = List.nil();

        for(id in Iter.fromList(followed)) {
            let canister: Microblog = actor(Principal.toText(id));
            let msgs = await canister.posts(since);
            for(msg in Iter.fromArray(msgs)) {
                all := List.push(msg, all)
            }
        };

        List.toArray(all)
    };
};
