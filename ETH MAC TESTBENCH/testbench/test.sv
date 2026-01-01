class simple_test extends uvm_test;
  env e;

  `uvm_component_utils(simple_test)

  function new(string name="simple_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    e = env::type_id::create("e", this);
  endfunction

  task run_phase(uvm_phase phase);
    // Declare before any statements to keep the compiler happy
    simple_sequence seq;

    phase.raise_objection(this);

    seq = simple_sequence::type_id::create("seq");
    seq.start(e.agent_tx.seqr);

    #20000;
    phase.drop_objection(this);
  endtask
endclass
