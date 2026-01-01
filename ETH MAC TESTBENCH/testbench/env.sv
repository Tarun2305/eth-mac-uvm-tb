class env extends uvm_env;

    axi_stream_agent agent_tx;
    axi_stream_agent agent_rx;
    scoreboard sb;

    `uvm_component_utils(env)

    function new(string name="env", uvm_component parent=null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        agent_tx = axi_stream_agent::type_id::create("agent_tx", this);
        agent_rx = axi_stream_agent::type_id::create("agent_rx", this);
        sb       = scoreboard::type_id::create("sb", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      agent_tx.mon.ap.connect(sb.exp_fifo.analysis_export); // 		expected
      agent_rx.mon.ap.connect(sb.act_fifo.analysis_export); // 		actual
    endfunction


endclass
