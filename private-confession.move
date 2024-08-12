module private_confession_addr::private_confession {
    use aptos_framework::aptos_account;
    use aptos_framework::event;
    use aptos_framework::signer;
    use std::string::{utf8, String};
    use aptos_std::table::{Self, Table};

    struct Confession has key {
        fb_id: u64,
        message: String,
    }

    struct FeedbackCounter has key {
        count: u64,
    }

    struct ConfessionBook has key {
        feedbacks: Table<u64, Confession>,
    }

    struct ConfessionCount has key, store {
        count: u64,
    }
    public entry fun isAdmin(addr:address){
        assert!(addr == @private_confession_addr, 5);
    }
    
    public entry fun initialize_account(account:&signer, msg:String) {
        let account_address = signer::address_of(account);
        isAdmin(account_address);
        if (!exists<Confession>(account_address)) {
            let fb = Confession{
                fb_id:0,
                message: msg,
            };
            move_to(account, fb);
        };
        if (!exists<ConfessionCount>(account_address)) {
            let fb_counter = ConfessionCount{
                count:0
            };
            move_to(account, fb_counter);
        };
    }

    public fun send_feedback(account: &signer, feedback_msg: String) acquires ConfessionCount, Confession  {
        let account_address = signer::address_of(account);
        assert!(exists<ConfessionCount>(account_address), 0); // Ensure ConfessionCount exists
        let fb_count = borrow_global_mut<ConfessionCount>(account_address);
        let fb_body = borrow_global_mut<Confession>(account_address);

        fb_count.count = fb_count.count + 1;

        fb_body.fb_id = fb_count.count;

        fb_body.message = feedback_msg;

        let feedback = Confession {
            fb_id: fb_count,
            message: feedback_msg,
        };

        let feedback_book = borrow_global_mut<ConfessionBook>(&account_address);
        table::add(&mut feedback_book.feedbacks, fb_count, feedback);

        borrow_global_mut<ConfessionCount>(&account_address).count = fb_count;
    }

    public fun fetch_feedback(account: &signer): String acquires Confession {
        let account_address = signer::address_of(account);
        assert!(exists<ConfessionBook>(account_address), 0); // Ensure ConfessionBook exists
        let feedback_book = borrow_global<Confession>(account_address);
        feedback_book.message
        table::borrow(&feedback_book.feedbacks, fb_id)
    }
}
