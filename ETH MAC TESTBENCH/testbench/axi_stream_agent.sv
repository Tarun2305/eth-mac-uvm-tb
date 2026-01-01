class axi_stream_agent extends uvm_agent;

  axi_stream_driver  drv;
  axi_stream_monitor mon;
  uvm_sequencer #(axi_stream_pkt) seqr;

  `uvm_component_utils(axi_stream_agent)

  function new(string name="axi_stream_agent", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    drv  = axi_stream_driver::type_id::create("drv", this);
    mon  = axi_stream_monitor::type_id::create("mon", this);
    seqr = uvm_sequencer#(axi_stream_pkt)::type_id::create("seqr", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction

endclass
