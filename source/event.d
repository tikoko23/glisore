module event;

alias ev_uniqueid_t = ulong;

class Event(ArgT)
{
    private:
    ev_uniqueid_t available = 1;
    
    static if (!is(ArgT == void))
        void delegate(ArgT)[ev_uniqueid_t] connection_list;
    else
        void delegate()[ev_uniqueid_t] connection_list;
    
    public:

    static if (!is(ArgT == void))
    {

        ev_uniqueid_t bind(void delegate(ArgT) fn)
        {
            this.connection_list[available] = fn;
            ++available;
            return available - 1;
        }

        void delegate(ArgT) getConnectedById(ev_uniqueid_t id)
        {
            return this.connection_list[id];
        }

        ref void delegate(ArgT)[ev_uniqueid_t] getConnected()
        {
            return this.connection_list;
        }

        ulong trigger(ArgT arg)
        {
            ulong trig_cnt = 0;

            foreach (fn; this.connection_list)
            {
                fn(arg);
                ++trig_cnt;
            }

            return trig_cnt;
        }
    } else {
        ev_uniqueid_t bind(void delegate() fn)
        {
            this.connection_list[available] = fn;
            ++available;
            return available - 1;
        }

        void delegate() getConnectedById(ev_uniqueid_t id)
        {
            return this.connection_list[id];
        }

        ref void delegate()[ev_uniqueid_t] getConnected()
        {
            return this.connection_list;
        }

        ulong trigger()
        {
            ulong trig_cnt = 0;

            foreach (fn; this.connection_list)
            {
                fn();
                ++trig_cnt;
            }

            return trig_cnt;
        }
    }

    void unbind(ev_uniqueid_t id)
    {
        this.connection_list.remove(id);
    }
}
