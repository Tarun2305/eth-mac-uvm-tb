class scoreboard extends uvm_component;
  uvm_tlm_analysis_fifo #(axi_stream_pkt) exp_fifo;
  uvm_tlm_analysis_fifo #(axi_stream_pkt) act_fifo;

  `uvm_component_utils(scoreboard)

  function new(string name="scoreboard", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    exp_fifo = new("exp_fifo", this);
    act_fifo = new("act_fifo", this);
  endfunction

  task run_phase(uvm_phase phase);
    axi_stream_pkt e, a;
    forever begin
      exp_fifo.get(e); // blocks until TX frame arrives
      act_fifo.get(a); // blocks until RX frame arrives
      if (e.data.size() != a.data.size() || e.data != a.data)
        `uvm_error("MISMATCH", $sformatf("RX != TX (len %0d vs %0d)", a.data.size(), e.data.size()))
      else
        `uvm_info("MATCH", $sformatf("Frame matched (len=%0d)", a.data.size()), UVM_LOW)
    end
  endtask
endclass
